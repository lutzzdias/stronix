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
    var muscle: String? // TODO: Create enum (back, shoulders, legs, chest, arms, ...)
    var equipment: String? // TODO: Create enum (barbell, dumbbell, machine, ...)

    init(id: UUID = UUID(), name: String, desc: String? = nil, muscle: String? = nil, equipment: String? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
        self.muscle = muscle
        self.equipment = equipment
    }
    
    static let sampleData: [Exercise] = [
        Exercise(name: "Pulldown"),
        Exercise(name: "Squat"),
        Exercise(name: "Preacher Curls"),
        Exercise(name: "Triceps Pushdown"),
        Exercise(name: "Bench Press"),
        Exercise(name: "Shoulder Press")
    ]
}
