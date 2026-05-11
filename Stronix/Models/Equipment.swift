//
//  Equipment.swift
//  Stronix
//
//  Created by Thiago Dias on 11/05/26.
//

import Foundation
import SwiftData

@Model
class Equipment {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String

    @Relationship(deleteRule: .nullify, inverse: \Exercise.equipment)
    var exercises: [Exercise]?

    init(id: UUID = UUID(), name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

extension Equipment {
    /// Checks whether `name` is already taken by another equipment.
    /// - Parameters:
    ///   - name: The proposed equipment name.
    ///   - excludingID: When editing, pass the current equipment's `id` so it doesn't match itself.
    ///   - context: The `ModelContext` used to query existing equipment.
    /// - Returns: `true` if an equipment with the same name (case-insensitive, trimmed) exists.
    static func isDuplicateName(_ name: String, excludingID: UUID? = nil, in context: ModelContext) throws -> Bool {
        var descriptor = FetchDescriptor<Equipment>()
        descriptor.propertiesToFetch = [\.name, \.id]
        let allEquipment = try context.fetch(descriptor)
        let trimmed = name.trimmingCharacters(in: .whitespaces).lowercased()
        return allEquipment.contains { equipment in
            equipment.name.trimmingCharacters(in: .whitespaces).lowercased() == trimmed
                && equipment.id != excludingID
        }
    }
}
