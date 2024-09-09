//
//  SampleData.swift
//  Stronix
//
//  Created by Thiago Dias on 20/08/24.
//

import Foundation

extension Exercise {
    static let sample: [Exercise] = [
        Exercise(
            name: "Pulldown",
            desc: "Pull the bar down, very similar to a pullup",
            equipment: "Machine",
            muscle: "Lats"
        ),
        Exercise(name: "Squat"),
        Exercise(name: "Preacher Curls"),
        Exercise(name: "Triceps Pushdown"),
        Exercise(name: "Bench Press"),
        Exercise(name: "Shoulder Press")
    ]
}

extension Set {
    static let sample: [Set] =
        [
           Set(repetitions: 12, minTargetRepetitions: 8, maxTargetRepetitions: 12, weight: 22.5, tag: .failure, comment: "Felt pain in the shoulder"),
           Set(repetitions: 10, minTargetRepetitions: 8, maxTargetRepetitions: 12, weight: 22.5),
           Set(repetitions: 8, minTargetRepetitions: 8, maxTargetRepetitions: 12, weight: 25, tag: .failure)
       ]
    
}

extension WorkoutExercise {
    static let sample: [WorkoutExercise] = [
        WorkoutExercise(exercise: Exercise.sample[0], sets: Set.sample),
        WorkoutExercise(exercise: Exercise.sample[5], sets: Set.sample),
        WorkoutExercise(exercise: Exercise.sample[2], sets: Set.sample),
    ]
}

extension Workout {
    static let sample: [Workout] = [
        Workout(
            name: "Chest and Triceps",
            comment: "Exercises related with the muscles responsible for pushing",
            end: Date.now.addingTimeInterval(10),
            exercises: WorkoutExercise.sample
        ),
        Workout(
            name: "Back and Biceps",
            comment: "Exercises related with the muscles responsible for pulling",
            end: Date.now.addingTimeInterval(250),
            exercises: WorkoutExercise.sample
        ),
        Workout(
            name: "Legs",
            comment: "Death ☠️",
            end: Date.now.addingTimeInterval(500),
            exercises: WorkoutExercise.sample
        ),
    ]
}
