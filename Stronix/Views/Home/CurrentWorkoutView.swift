//
//  CurrentWorkoutView.swift
//  Stronix
//
//  Created by Thiago Dias on 28/08/24.
//

import SwiftUI
import SwiftData

struct CurrentWorkoutView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var workout: Workout = Workout()
    @State private var isShowingExercisesSheet = false
    
    var body: some View {
        TimerView(startDate: workout.start)
        
        List {
            // MARK: Title and description
            Section {
                TextField("Name", text: $workout.name)
                TextField("Description", text: $workout.comment, axis: .vertical)
            }
            
            // MARK: Exercises
            Section("Exercises") {
                ForEach(workout.sortedExercises) { workoutExercise in
                    NavigationLink(destination: WorkoutExerciseView(workout: workout, workoutExercise: workoutExercise)) {
                        Text(workoutExercise.exercise?.name ?? "")
                    }
                }
                .onMove { source, destination in workout.moveExercises(from: source, to: destination)}
                .onDelete{ indexes in workout.removeExercises(at: indexes)}
                
                Button("Add exercise", systemImage: "plus") {
                    isShowingExercisesSheet = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    workout.end = Date.now
                    context.insert(workout)
                    try? context.save()
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $isShowingExercisesSheet) {
            AddExerciseSheetView(
                addedExercises: Set(workout.exercises),
                onAdd: { selection in
                    for exercise in selection {
                        workout.appendExercise(WorkoutExercise(exercise: exercise))
                    }
                    isShowingExercisesSheet = false
                }
            )
        }
    }
}

#Preview {
    let preview = Preview()
    
    return NavigationStack {
        CurrentWorkoutView()
            .modelContainer(preview.container)
    }
}
