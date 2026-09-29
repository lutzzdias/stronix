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
    
    @MainActor
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            container = try ModelContainer(for: StronixSchema.make(), configurations: config)
        } catch {
            fatalError("Could not create preview container")
        }

        addData()
    }

    /// Seeds sample data synchronously.
    ///
    /// Must stay synchronous: a detached `Task` would let previews render before
    /// the data exists, so lists would flash empty or appear broken. `@MainActor`
    /// on the initializer is what makes touching `mainContext` here legal.
    @MainActor
    private func addData() {
        let exercises = Exercise.sample
        let sets = WorkoutSet.sample

        for exercise in exercises {
            container.mainContext.insert(exercise)
        }

        let workoutExercise = WorkoutExercise(exercise: exercises[0])

        for workoutSet in sets {
            container.mainContext.insert(workoutSet)
            workoutExercise.sets.append(workoutSet)
        }

        container.mainContext.insert(workoutExercise)

        let workout = Workout(
            name: "Chest and Triceps",
            comment: "Exercises related with the muscles responsible for pushing",
            end: Date.now.addingTimeInterval(10)
        )

        workout.workoutExercises = [workoutExercise]

        container.mainContext.insert(workout)
    }
}
