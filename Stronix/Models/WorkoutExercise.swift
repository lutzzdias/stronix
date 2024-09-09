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
    var comment: String?
    
    var exercise: Exercise
    var sets: [WorkoutSet]
    
    init(id: UUID = UUID(), comment: String? = nil, exercise: Exercise, sets: [WorkoutSet] = []) {
        self.id = id
        self.comment = comment
        self.exercise = exercise
        self.sets = sets
    }
}
