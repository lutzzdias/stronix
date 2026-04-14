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
    
    @State private var workout: Workout? = nil
    @State private var isShowingExercisesSheet = false
    
    private var workoutName: Binding<String> {
        Binding<String> {
            workout?.name ?? ""
        } set: { name in
            workout?.name = name
        }
    }
    
    private var workoutDesc: Binding<String> {
        Binding<String> {
            workout?.comment ?? ""
        } set: { desc in
            workout?.comment = desc
        }
    }
    
    var body: some View {
        TimerView(startDate: workout?.start ?? Date.now)
        
        List {
            // MARK: Title and description
            Section {
                TextField("Name", text: workoutName)
                TextField("Description", text: workoutDesc, axis: .vertical)
            }
            
            // MARK: Exercises
            Section("Exercises") {
                ForEach(workout?.sortedExercises ?? []) { workoutExercise in
                    NavigationLink(destination: WorkoutExerciseView(workoutExercise: workoutExercise)) {
                        Text(workoutExercise.exercise?.name ?? "")
                    }
                }
                .onMove { source, destination in workout?.moveExercises(from: source, to: destination)}
                .onDelete{ indexes in workout?.removeExercises(at: indexes)}
                
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
                    guard let workout else { return } // TODO: add logs
                    workout.end = Date.now
                    context.insert(workout)
                    try? context.save()
                    
                    self.workout = nil
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    workout = nil
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isShowingExercisesSheet) {
            AddExerciseSheetView(
                addedExercises: Set(workout?.exercises ?? []),
                onAdd: { selection in
                    for exercise in selection {
                        workout?.appendExercise(WorkoutExercise(exercise: exercise))
                    }
                    isShowingExercisesSheet = false
                }
            )
        }
        .onAppear {
            if (workout == nil) { workout = Workout()}
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
