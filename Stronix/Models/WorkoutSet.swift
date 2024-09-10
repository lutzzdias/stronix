//
//  WorkoutSet.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var repetitions: Int
    var weight: Double
    var completed: Bool
    var minTargetRepetitions: Int?
    var maxTargetRepetitions: Int?
    var tag: Tag?
    var comment: String?
    
    init(id: UUID = UUID(), repetitions: Int = 0, weight: Double = 0, completed: Bool = false, minTargetRepetitions: Int? = nil, maxTargetRepetitions: Int? = nil, tag: Tag? = nil, comment: String? = nil) {
        self.id = id
        self.repetitions = repetitions
        self.weight = weight
        self.completed = completed
        self.minTargetRepetitions = minTargetRepetitions
        self.maxTargetRepetitions = maxTargetRepetitions
        self.tag = tag
        self.comment = comment
    }
}
