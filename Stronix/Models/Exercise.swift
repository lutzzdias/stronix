//
//  Exercise.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var desc: String?
    @Relationship var equipment: Equipment?
    @Relationship(inverse: \MuscleGroup.primaryExercises) var primaryMuscles: [MuscleGroup]
    @Relationship(inverse: \MuscleGroup.secondaryExercises) var secondaryMuscles: [MuscleGroup]
    var isArchived: Bool = false

    /// When the exercise was added to the catalog, used to surface recent additions.
    /// Defaulted so existing records migrate lightweightly; they all share the
    /// migration timestamp and so have no meaningful order among themselves.
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify) var workoutExercises: [WorkoutExercise] = []

    init(id: UUID = UUID(), name: String, desc: String? = nil, equipment: Equipment? = nil, primaryMuscles: [MuscleGroup] = [], secondaryMuscles: [MuscleGroup] = [], createdAt: Date = Date.now) {
        self.id = id
        self.name = name
        self.desc = desc
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.createdAt = createdAt
    }
}

extension Exercise {
    static let activePredicate = #Predicate<Exercise> { exercise in !exercise.isArchived }

    /// How many times the exercise has been used across all workouts.
    ///
    /// Derived from the `workoutExercises` relationship, so it cannot be used in a
    /// `#Predicate` or `SortDescriptor` — callers sort in memory instead.
    var usageCount: Int { workoutExercises.count }
}

extension Exercise: UniquelyNamed {
    /// Archived exercises don't block a name, so the catalog can reuse a retired name.
    static var duplicateScope: Predicate<Exercise>? { activePredicate }

    static var nameComparisonProperties: [PartialKeyPath<Exercise>] { [\.name, \.id] }
}
