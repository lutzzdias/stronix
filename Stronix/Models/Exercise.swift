//
//  Exercise.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
class Exercise {
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

    @Relationship(deleteRule: .nullify) var workoutExercises: [WorkoutExercise]?

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
    var usageCount: Int { workoutExercises?.count ?? 0 }

    /// Checks whether `name` is already taken by another non-archived exercise.
    /// - Parameters:
    ///   - name: The proposed exercise name.
    ///   - excludingID: When editing, pass the current exercise's `id` so it doesn't match itself.
    ///   - context: The `ModelContext` used to query existing exercises.
    /// - Returns: `true` if a non-archived exercise with the same name (case-insensitive, trimmed) exists.
    static func isDuplicateName(_ name: String, excludingID: UUID? = nil, in context: ModelContext) throws -> Bool {
        var descriptor = FetchDescriptor<Exercise>(predicate: activePredicate)
        descriptor.propertiesToFetch = [\.name, \.id]
        let exercises = try context.fetch(descriptor)
        let trimmed = name.trimmingCharacters(in: .whitespaces).lowercased()
        return exercises.contains { exercise in
            exercise.name.trimmingCharacters(in: .whitespaces).lowercased() == trimmed
                && exercise.id != excludingID
        }
    }
}
