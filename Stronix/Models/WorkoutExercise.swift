//
//  WorkoutExercise.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
class WorkoutExercise {
    @Attribute(.unique) var id: UUID
    var desc: String?
    
    var exercise: Exercise
    var sets: [Set]?
    
    init(id: UUID = UUID(), desc: String? = nil, exercise: Exercise, sets: [Set]?) {
        self.id = id
        self.desc = desc
        self.exercise = exercise
        self.sets = sets
    }
}
