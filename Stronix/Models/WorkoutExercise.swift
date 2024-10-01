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
    var comment: String
    
    @Relationship var workout: Workout?
    @Relationship(deleteRule: .nullify) var exercise: Exercise? // TODO: improve deletion logic
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    
    init(id: UUID = UUID(), comment: String = "", exercise: Exercise, sets: [WorkoutSet] = []) {
        self.id = id
        self.comment = comment
        self.exercise = exercise
        self.sets = sets
    }
}
