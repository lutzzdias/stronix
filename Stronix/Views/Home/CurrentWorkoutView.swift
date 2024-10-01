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
                ForEach(workout?.exercises ?? []) { workoutExercise in
                    NavigationLink(destination: WorkoutExerciseView(workoutExercise: workoutExercise)) {
                        Text(workoutExercise.exercise?.name ?? "")
                    }
                }
                
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
                    workout?.end = Date.now
                    context.insert(workout!)
                    workout = nil
                    try? context.save()
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
                onAdd: { selection in
                Task { @MainActor in
                    for exercise in selection {
                        let we = WorkoutExercise(exercise: exercise)
                        context.insert(we)
                        we.workout = workout
                        workout?.exercises.append(we)
                    }
                }
                
                isShowingExercisesSheet = false
            })
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
