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
        Text("\(workout.id)")
        // MARK: Timer
        HStack {
            HStack {
                Image(systemName: "clock")
                Text(workout.start, style: .timer)
            }
            
            Spacer()
            
            // TODO: Add rest timer
        }
        .padding(.horizontal)
        
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
                    debugPrint(workout.duration)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    workout.end = Date.now
                    context.insert(workout)
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    context.delete(workout)
                    try! context.save()
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
