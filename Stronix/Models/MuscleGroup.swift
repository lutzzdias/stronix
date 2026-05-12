//
//  MuscleGroup.swift
//  Stronix
//

import Foundation
import SwiftData

@Model
class MuscleGroup {
    @Attribute(.unique) var id: UUID
    var name: String
    var desc: String?

    @Relationship(deleteRule: .nullify)
    var primaryExercises: [Exercise]

    @Relationship(deleteRule: .nullify)
    var secondaryExercises: [Exercise]

    init(id: UUID = UUID(), name: String, desc: String? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
        self.primaryExercises = []
        self.secondaryExercises = []
    }
}

extension MuscleGroup {
    /// Checks whether `name` is already taken by another muscle group.
    /// - Parameters:
    ///   - name: The proposed muscle group name.
    ///   - excludingID: When editing, pass the current muscle group's `id` so it doesn't match itself.
    ///   - context: The `ModelContext` used to query existing muscle groups.
    /// - Returns: `true` if a muscle group with the same name (case-insensitive, trimmed) exists.
    static func isDuplicateName(_ name: String, excludingID: UUID? = nil, in context: ModelContext) throws -> Bool {
        var descriptor = FetchDescriptor<MuscleGroup>()
        descriptor.propertiesToFetch = [\.name, \.id]
        let allMuscleGroups = try context.fetch(descriptor)
        let trimmed = name.trimmingCharacters(in: .whitespaces).lowercased()
        return allMuscleGroups.contains { muscleGroup in
            muscleGroup.name.trimmingCharacters(in: .whitespaces).lowercased() == trimmed
                && muscleGroup.id != excludingID
        }
    }
}
