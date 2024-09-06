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
    
    private var workoutName: Binding<String> {
        Binding<String> {
            workout?.name ?? ""
        } set: { name in
            workout?.name = name
        }
    }
    
    private var workoutDesc: Binding<String> {
        Binding<String> {
            workout?.desc ?? ""
        } set: { desc in
            workout?.desc = desc
        }
    }
    
    var body: some View {
        // MARK: Timer
        HStack {
            HStack {
                Image(systemName: "clock")
                Text(workout?.start ?? Date.now, style: .timer)
            }
            
            Spacer()
            
            // TODO: Add rest timer
        }
        .padding(.horizontal)
        
        List {
            
            // MARK: Title and description
            Section {
                TextField("Name", text: workoutName)
                TextField("Description", text: workoutDesc)
            }
            
            // MARK: Exercises
            Section("Exercises") {
                // TODO: Fix preview crash when uncommenting this
                ForEach(workout?.exercises ?? []) { workoutExercise in
                    Text(workoutExercise.exercise.name)
                }
                
                Button("Add exercise", systemImage: "plus") {
                    // TODO: add workoutExercise
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    workout?.end = Date.now
                    context.insert(workout!)
                    workout = nil
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
        .navigationBarBackButtonHidden()
        .onAppear {
            workout = Workout()
        }
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
