//
//  Set.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@Model
class Set {
    @Attribute(.unique) var id: UUID
    var repetitions: Int
    var minTargetRepetitions: Int?
    var maxTargetRepetitions: Int?
    var weight: Double
    var tag: Tag?
    var comment: String?
    
    init(id: UUID = UUID(), repetitions: Int = 0, minTargetRepetitions: Int? = nil, maxTargetRepetitions: Int? = nil, weight: Double = 0, tag: Tag? = nil, comment: String? = nil) {
        self.id = id
        self.repetitions = repetitions
        self.minTargetRepetitions = minTargetRepetitions
        self.maxTargetRepetitions = maxTargetRepetitions
        self.weight = weight
        self.tag = tag
        self.comment = comment
    }
}
