//
//  WorkoutExerciseView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI

struct WorkoutExerciseView: View {
    let workout: Workout
    @Bindable var workoutExercise: WorkoutExercise
    @State var selectedSet: WorkoutSet? = nil
    
    var body: some View {
        Text(workout.name)
        TimerView(startDate: workout.start)
        
        List {
            Section {
                TextField("Comment", text: $workoutExercise.comment)
                
                // TODO: initialize empty and only show image when current/past set (iron like)
                ForEach(Array(workoutExercise.sortedSets.enumerated()), id: \.element.id) { index, workoutSet in
                    HStack {
                        workoutSet.completed ? Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) : Image(systemName: "arrow.forward.circle").foregroundStyle(.blue)
                        Text("\(String(format: "%g", workoutSet.weight ?? 0)) × \(workoutSet.repetitions ?? 0)")
                        Spacer()
                        Text("\(index + 1)")
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        if (selectedSet == workoutSet) { selectedSet = nil }
                        else { selectedSet = workoutSet }
                    }
                }
                .onMove { source, destination in workoutExercise.moveSets(from: source, to: destination) }
                .onDelete(perform: delete)
                
                Button {
                    workoutExercise.appendSet(WorkoutSet())
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add set")
                    }
                }
            }
            
            // TODO: Fetch previous workoutSets for this exercise
        }
        
        // MARK: Set editor
        if let selectedSet {
            SetEditorView(set: selectedSet) {
                self.selectedSet = nil
            }
        }
    }
    
    func delete(at indexes: IndexSet) {
        let removedSet = workoutExercise.removeSets(at: indexes)
        if let selectedSet, removedSet.contains(where: {set in set.id == selectedSet.id }) {
            self.selectedSet = nil
        }
    }
}

#Preview {
    let preview = Preview()
    let workoutExercise = WorkoutExercise(exercise: Exercise(name: "Test"))
    preview.container.mainContext.insert(workoutExercise)
    
    return WorkoutExerciseView(workout: Workout(), workoutExercise: workoutExercise)
        .modelContainer(preview.container)
}
