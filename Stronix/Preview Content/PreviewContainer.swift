//
//  PreviewContainer.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

struct Preview {
    let container: ModelContainer
    
    init() {
        let models: [any PersistentModel.Type] = [Exercise.self, Set.self, WorkoutExercise.self, Workout.self]
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(models)
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create preview container")
        }
        
        addData()
    }
    
    func addData() {
        Task { @MainActor in
            let exercises = Exercise.sample
            let sets = Set.sample
            
            for exercise in exercises {
                container.mainContext.insert(exercise)
            }

            let workoutExercise = WorkoutExercise(exercise: exercises.first!)
            
            for s in sets {
                container.mainContext.insert(s)
                workoutExercise.sets.append(s)
            }
            
            container.mainContext.insert(workoutExercise)
            
            let workout = Workout(
                name: "Chest and Triceps",
                comment: "Exercises related with the muscles responsible for pushing",
                end: Date.now.addingTimeInterval(10)
            )
            
            workout.exercises = [workoutExercise]
            
            container.mainContext.insert(workout)
        }
    }
}
