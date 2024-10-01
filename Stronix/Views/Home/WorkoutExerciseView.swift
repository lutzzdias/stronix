//
//  WorkoutExerciseView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI

struct WorkoutExerciseView: View {
    @Environment(\.modelContext) var context
    
    @Bindable var workoutExercise: WorkoutExercise
    @State var selectedSet: WorkoutSet? = nil
    
    var body: some View {
        Text(workoutExercise.workout?.name ?? "")
        TimerView(startDate: workoutExercise.workout?.start ?? Date.now)
        
        List {
            Section {
                TextField("Comment", text: $workoutExercise.comment)
                
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, workoutSet in
                    HStack {
                        Text("\(String(format: "%g", workoutSet.weight)) × \(workoutSet.repetitions)")
                        Spacer()
                        Text("\(index + 1)")
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        if (selectedSet == workoutSet) { selectedSet = nil }
                        else { selectedSet = workoutSet }
                    }
                }
                .onDelete(perform: delete)
                
                Button {
                    Task { @MainActor in
                        let workoutSet = WorkoutSet()
                        context.insert(workoutSet)
                        workoutExercise.sets.append(workoutSet)
                        try? context.save()
                    }
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
        if (selectedSet != nil) {
            var weight: Binding<String> {
                Binding<String> {
                    String(describing: selectedSet!.weight)
                } set: { weight in
                    selectedSet!.weight = Double(weight) ?? 0
                }
            }
            
            var reps: Binding<String> {
                Binding<String> {
                    String(describing: selectedSet!.repetitions)
                } set: { reps in
                    selectedSet!.repetitions = Int(reps) ?? 0
                }
            }
            
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    HStack {
                        HStack {
                            TextField("Weight", text: weight)
                                .keyboardType(.decimalPad)
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider().frame(height: 44)
                    
                    HStack {
                        HStack {
                            TextField("Reps", text: reps)
                                .keyboardType(.numberPad)
                            Text("reps")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
            }
            .padding(.horizontal)
        }
    }
    
    func delete(at indexes: IndexSet) {
        for index in indexes {
            let workoutSet = workoutExercise.sets.remove(at: index)
            if (workoutSet == selectedSet) { selectedSet = nil }
            context.delete(workoutSet)
        }
    }
}

#Preview {
    let preview = Preview()
    let workoutExercise = WorkoutExercise(exercise: Exercise(name: "Test"))
    preview.container.mainContext.insert(workoutExercise)
    
    return WorkoutExerciseView(workoutExercise: workoutExercise)
        .modelContainer(preview.container)
}
