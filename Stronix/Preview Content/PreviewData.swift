//
//  PreviewData.swift
//  Stronix
//
//  Created by Thiago Dias on 09/09/24.
//

import Foundation

extension Workout {
    static let sample: [Workout] = [
        Workout(
            name: "name",
            comment: "pretty hard",
            exercises: [
                WorkoutExercise(exercise: Exercise.sample.first!, sets: WorkoutSet.sample),
                WorkoutExercise(exercise: Exercise.sample.last!, sets: WorkoutSet.sample),
                WorkoutExercise(exercise: Exercise.sample.last!, sets: WorkoutSet.sample)
            ]
        ),
        Workout(name: "name2", comment: "pretty hard"),
        Workout(name: "name3", comment: "pretty hard")
    ]
}

extension Exercise {
    static let sample: [Exercise] = [
        Exercise(name: "Pulldown", desc: "Very similar to the pullup", equipment: "Machine", muscle: "Lats"),
        Exercise(name: "Incline Bench Press", desc: "The best exercise ever", equipment: "Dumbbell", muscle: "Chest"),
        Exercise(name: "Hammer Curls", desc: "The best ego exercise", equipment: "Dumbbell", muscle: "Biceps")
    ]
}

extension WorkoutSet {
    static let sample: [WorkoutSet] = [
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere"),
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere"),
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere")
    ]
}
