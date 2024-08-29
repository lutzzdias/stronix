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
    
    @Bindable var workout: Workout = Workout()
    
    var body: some View {
        // MARK: Timer
        HStack {
            HStack {
                Image(systemName: "clock")
                // TODO: update timer every second
                Text(workout.durationStr)
            }
            
            Spacer()
            
            // TODO: Add rest timer
        }
        .padding()
        
        List {
            
            // MARK: Title and description
            Section {
                TextField("Name", text: $workout.name)
                TextField("Description", text: $workout.desc)
            }
            
            // MARK: Exercises
            Section("Exercises") {
                // TODO: Fix preview crash when uncommenting this
//                ForEach(workout.exercises) { workoutExercise in
//                    Text(workoutExercise.exercise.name)
//                }
                
                Button("Add exercise", systemImage: "plus") {
                    print("Add exercise")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // TODO: Save properly
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    // TODO: Delete properly
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    let preview = Preview(Workout.self, WorkoutExercise.self, Exercise.self, Set.self)
    
    preview.addData(Exercise.sample)
    preview.addData(Set.sample)
    preview.addData(WorkoutExercise.sample)
    preview.addData(Workout.sample)
    
    return CurrentWorkoutView()
        .modelContainer(preview.container)
}
