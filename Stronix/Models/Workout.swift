//
//  Workout.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var desc: String?
    var start: Date
    var end: Date
    
    var exercises: [WorkoutExercise]?
    // var routineId: UUID TODO: create routines
    
    init(id: UUID = UUID(), name: String, desc: String? = nil, start: Date, end: Date, exercises: [WorkoutExercise]? = []) {
        self.id = id
        self.name = name
        self.desc = desc
        self.start = start
        self.end = end
        self.exercises = exercises
    }
    
    // TODO: number of sets completed
    
    // TODO: total weight lifted
    
    // TODO: calculate duration
}
