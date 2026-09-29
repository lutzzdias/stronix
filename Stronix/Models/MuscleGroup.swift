//
//  MuscleGroup.swift
//  Stronix
//

import Foundation
import SwiftData

@Model
final class MuscleGroup {
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

extension MuscleGroup: UniquelyNamed {
    static var nameComparisonProperties: [PartialKeyPath<MuscleGroup>] { [\.name, \.id] }
}
