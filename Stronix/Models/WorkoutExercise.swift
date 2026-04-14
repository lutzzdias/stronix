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
    var sortIndex: Int
    
    @Relationship var workout: Workout?
    @Relationship(deleteRule: .noAction) var exercise: Exercise?
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSet]
    
    init(id: UUID = UUID(), comment: String = "", exercise: Exercise, sets: [WorkoutSet] = [], sortIndex: Int = 0) {
        self.id = id
        self.comment = comment
        self.exercise = exercise
        self.sets = sets
        self.sortIndex = sortIndex
    }
    
    var sortedSets: [WorkoutSet] {
        sets.sorted { left, right in left.sortIndex < right.sortIndex }
    }
    
    func appendSet(_ set: WorkoutSet) {
        set.sortIndex = sets.count
        sets.append(set)
    }
    
    func removeSets(at offsets: IndexSet) -> [WorkoutSet] {
        let sorted = sortedSets
        let removed = offsets.map { index in sorted[index] }
        for removedSet in removed {
            sets.removeAll { set in set.id == removedSet.id }
        }
        for (index, set) in sortedSets.enumerated() {
            set.sortIndex = index
        }
        return removed
    }
    
    func moveSets(from source: IndexSet, to destination: Int) {
        var ordered = sortedSets
        ordered.move(fromOffsets: source, toOffset: destination)
        ordered.reorder()
    }
}

extension WorkoutExercise: Sortable {}
