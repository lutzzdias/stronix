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

    init(id: UUID = UUID(), name: String, desc: String? = nil, equipment: String? = nil, muscle: String? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
        self.muscle = muscle
        self.equipment = equipment
    }
}
