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
    var equipment: String? // TODO: Create enum (barbell, dumbbell, machine, ...)
    var muscle: String? // TODO: Create enum (back, shoulders, legs, chest, arms, ...)
    var isArchived: Bool = false
    
    @Relationship(deleteRule: .nullify) var workoutExercises: [WorkoutExercise]?

    init(id: UUID = UUID(), name: String, desc: String? = nil, equipment: String? = nil, muscle: String? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
        self.muscle = muscle
        self.equipment = equipment
    }
}

extension Exercise {
    static let activePredicate = #Predicate<Exercise> { exercise in !exercise.isArchived }

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
