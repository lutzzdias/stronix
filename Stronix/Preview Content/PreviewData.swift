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
                WorkoutExercise(exercise: Exercise.sample[0], sets: WorkoutSet.sample),
                WorkoutExercise(exercise: Exercise.sample[1], sets: WorkoutSet.sample),
                WorkoutExercise(exercise: Exercise.sample[2], sets: WorkoutSet.sample)
            ]
        ),
        Workout(name: "name2", comment: "pretty hard"),
        Workout(name: "name3", comment: "pretty hard")
    ]
}

extension Equipment {
    static let sample: [Equipment] = [
        Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional"),
        Equipment(name: "Dumbbell", icon: "dumbbell.fill"),
        Equipment(name: "Machine", icon: "gearshape.fill"),
    ]
}

extension MuscleGroup {
    static let sample: [MuscleGroup] = [
        MuscleGroup(name: "Back"),
        MuscleGroup(name: "Chest"),
        MuscleGroup(name: "Arms"),
    ]
}

extension Exercise {
    static let sample: [Exercise] = [
        Exercise(name: "Pulldown", desc: "Very similar to the pullup"),
        Exercise(name: "Incline Bench Press", desc: "The best exercise ever"),
        Exercise(name: "Hammer Curls", desc: "The best ego exercise"),
    ]
}

extension WorkoutSet {
    static let sample: [WorkoutSet] = [
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere"),
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere"),
        WorkoutSet(repetitions: 10, weight: 22.5, minTargetRepetitions: 6, maxTargetRepetitions: 8, tag: .failure, comment: "Felt pain somewhere")
    ]
}
