//
//  StronixSchema.swift
//  Stronix
//

import Foundation
import SwiftData

/// The single declaration of which models make up the persistent store.
///
/// Both the app's on-disk container (`StronixApp`) and the in-memory preview
/// container (`Preview`) build from this, so adding a model is a one-line change
/// instead of two that can silently drift apart.
enum StronixSchema {
    static let models: [any PersistentModel.Type] = [
        Workout.self,
        WorkoutExercise.self,
        WorkoutSet.self,
        Exercise.self,
        Equipment.self,
        MuscleGroup.self,
    ]

    static func make() -> Schema { Schema(models) }
}
