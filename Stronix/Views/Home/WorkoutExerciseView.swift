//
//  WorkoutExerciseView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI
import SwiftData

struct WorkoutExerciseView: View {
    @Environment(\.modelContext) var modelContext
    
    let workout: Workout
    @Bindable var workoutExercise: WorkoutExercise
    @State var selectedSet: WorkoutSet? = nil
    
    /// Past completed workouts containing the same exercise, most recent first (max 3).
    /// Loaded once in .task to avoid fetching on every body evaluation.
    @State private var exerciseHistory: [(id: UUID, date: Date, sets: [WorkoutSet])] = []
    
    var body: some View {
        Text(workout.name)
        TimerView(startDate: workout.start)
        
        List {
            Section {
                TextField("Comment", text: $workoutExercise.comment)
                
                // TODO: initialize empty and only show image when current/past set (iron like)
                ForEach(Array(workoutExercise.sortedSets.enumerated()), id: \.element.id) { index, workoutSet in
                    HStack {
                        if workoutSet.completed {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        } else {
                            Image(systemName: "arrow.forward.circle").foregroundStyle(.blue)
                                .opacity(selectedSet == workoutSet ? 1 : 0)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(String(format: "%g", workoutSet.weight ?? 0)) × \(workoutSet.repetitions ?? 0)")
                            if let comment = workoutSet.comment, !comment.isEmpty {
                                Text(comment)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .italic()
                            }
                        }
                        Spacer()
                        if let rpe = workoutSet.rpe {
                            Text(rpe.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let tag = workoutSet.tag {
                            Text(tag.shortLabel)
                                .font(.caption2).bold()
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(.secondary, in: .capsule)
                        }
                        Text("\(index + 1)")
                            .foregroundStyle(.secondary)
                    }
                    .alignmentGuide(.listRowSeparatorLeading) { dimensions in dimensions[.leading] }
                    .onTapGesture {
                        if (selectedSet == workoutSet) { selectedSet = nil }
                        else { selectedSet = workoutSet }
                    }
                }
                .onMove { source, destination in workoutExercise.moveSets(from: source, to: destination) }
                .onDelete(perform: delete)
                
                Button {
                    let newSet = WorkoutSet()
                    workoutExercise.appendSet(newSet)
                    // Pre-fill from history or previous set
                    if let values = workoutExercise.autoFillValues(for: newSet, using: modelContext) {
                        newSet.weight = values.weight
                        newSet.repetitions = values.reps
                    }
                    selectedSet = newSet
                    Log.persistence.debug("Set added to exercise: \(workoutExercise.exercise?.name ?? "unknown exercise")")
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add set")
                    }
                }
            }
            
            // MARK: Exercise history (last 3 completed workouts)
            if !exerciseHistory.isEmpty {
                Section {
                    ForEach(exerciseHistory, id: \.id) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(AppFormatter.shortDate(entry.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ForEach(entry.sets) { set in
                                Text("\(String(format: "%g", set.weight ?? 0)) × \(set.repetitions ?? 0)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                } header: {
                    Text("History")
                }
            }
        }
        .task { loadHistory() }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            // Only pre-fill the first set from history on page load
            if let firstSet = workoutExercise.sortedSets.first,
               firstSet.weight == nil || firstSet.repetitions == nil,
               let values = workoutExercise.autoFillValues(for: firstSet, using: modelContext) {
                if firstSet.weight == nil { firstSet.weight = values.weight }
                if firstSet.repetitions == nil { firstSet.repetitions = values.reps }
            }
            // Auto-select first uncompleted set
            if selectedSet == nil {
                selectedSet = workoutExercise.sortedSets.first { !$0.completed }
            }
        }
        .onChange(of: selectedSet) {
            // Auto-fill the newly selected set (from previous set or history)
            guard let set = selectedSet,
                  set.weight == nil || set.repetitions == nil,
                  let values = workoutExercise.autoFillValues(for: set, using: modelContext) else { return }
            if set.weight == nil { set.weight = values.weight }
            if set.repetitions == nil { set.repetitions = values.reps }
        }
        
        // MARK: Set editor
        if let selectedSet {
            SetEditorView(
                set: selectedSet
            ) { _ in
                // Advance to the next uncompleted set
                self.selectedSet = workoutExercise.sortedSets.first { !$0.completed }
            }
        }
    }
    
    func delete(at indexes: IndexSet) {
        let removedSet = workoutExercise.removeSets(at: indexes)
        if let selectedSet, removedSet.contains(where: {set in set.id == selectedSet.id }) {
            self.selectedSet = nil
        }
    }
    
    private func loadHistory() {
        guard let exerciseId = workoutExercise.exercise?.id else { return }
        exerciseHistory = WorkoutExercise.fetchHistory(for: exerciseId, excluding: workout.id, using: modelContext)
            .prefix(3)
            .map { (id: $0.id, date: $0.workout?.start ?? .distantPast, sets: $0.sortedSets) }
    }
}

#Preview {
    let preview = Preview()
    let workoutExercise = WorkoutExercise(exercise: Exercise(name: "Test"))
    preview.container.mainContext.insert(workoutExercise)
    
    return WorkoutExerciseView(workout: Workout(), workoutExercise: workoutExercise)
        .modelContainer(preview.container)
}
