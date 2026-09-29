//
//  Equipment.swift
//  Stronix
//
//  Created by Thiago Dias on 11/05/26.
//

import Foundation
import SwiftData

@Model
final class Equipment {
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

extension Equipment: UniquelyNamed {
    static var nameComparisonProperties: [PartialKeyPath<Equipment>] { [\.name, \.id] }
}
