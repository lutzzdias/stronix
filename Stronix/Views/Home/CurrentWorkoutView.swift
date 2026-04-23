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
    @Environment(ErrorHandler.self) var errorHandler
    @Environment(RestTimer.self) var restTimer
    
    @State var workout: Workout
    @State private var isShowingExercisesSheet = false
    @State private var isShowingSummary = false
    
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
        .onAppear { Log.workout.info("Workout started") }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish") {
                    Log.workout.info("Summary generated")
                    isShowingSummary = true
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    restTimer.stop()
                    Log.workout.info("Workout cancelled")
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isShowingExercisesSheet) {
            AddExerciseSheetView(
                addedExercises: Set(workout.exercises),
                onAdd: { selection in
                    for exercise in selection {
                        workout.appendExercise(WorkoutExercise(exercise: exercise))
                        Log.persistence.debug("Exercise added to workout: \(exercise.name)")
                    }
                    isShowingExercisesSheet = false
                }
            )
        }
        .sheet(isPresented: $isShowingSummary) {
            WorkoutSummarySheet(workout: workout, onSave: {
                workout.finish()
                context.insert(workout)
                restTimer.stop()
                do {
                    try context.save()
                    Log.workout.info("Workout saved: \(workout.name)")
                } catch {
                    Log.persistence.error("Failed to save workout: \(error.localizedDescription)")
                    errorHandler.show("Could not save your workout. Please try again.")
                }
                isShowingSummary = false
                dismiss()
            }, onCancel: {
                Log.workout.info("Summary cancelled")
                isShowingSummary = false
            })
        }
    }
}

#Preview {
    let preview = Preview()
    
    return NavigationStack {
        CurrentWorkoutView(workout: Workout())
            .modelContainer(preview.container)
    }
}
