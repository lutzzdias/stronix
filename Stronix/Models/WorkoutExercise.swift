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

// MARK: - Auto-Fill

extension WorkoutExercise {
    
    /// Returns suggested (weight, reps) for a given set, or nil if no data is available.
    ///
    /// Algorithm:
    /// - Set 0: uses the first set of the most recent historical workout for this exercise.
    /// - Set N > 0: scans history for a workout where sets 0 ..  N all match the current workout's
    ///   values exactly (weight AND reps). If found, uses that workout's set N. Otherwise falls
    ///   back to copying set N-1 from the current workout.
    func autoFillValues(for set: WorkoutSet, using context: ModelContext) -> (weight: Double, reps: Int)? {
        let sorted = sortedSets
        guard let setIndex = sorted.firstIndex(where: { $0.id == set.id }),
              let exercise else { return nil }
        
        let history = Self.fetchHistory(for: exercise.id, excluding: workout?.id, using: context)
        
        if setIndex == 0 {
            // First set: use first set of most recent historical workout
            guard let histSet = history.first?.sortedSets.first,
                  let w = histSet.weight, let r = histSet.repetitions else { return nil }
            return (w, r)
        }
        
        // Set N > 0: try progressive match first
        if let match = progressiveMatch(at: setIndex, in: sorted, history: history) {
            return match
        }
        
        // Fallback: copy previous set in current workout
        let prev = sorted[setIndex - 1]
        guard let w = prev.weight, let r = prev.repetitions else { return nil }
        return (w, r)
    }
    
    /// Finds a historical workout where sets 0 .. index all match the current workout exactly,
    /// then returns that workout's set at `index`.
    private func progressiveMatch(at index: Int, in currentSets: [WorkoutSet], history: [WorkoutExercise]) -> (weight: Double, reps: Int)? {
        for past in history {
            let pastSets = past.sortedSets
            guard pastSets.count > index else { continue }
            
            // Check that all preceding sets match exactly
            var allMatch = true
            for i in 0..<index {
                if currentSets[i].weight != pastSets[i].weight ||
                   currentSets[i].repetitions != pastSets[i].repetitions {
                    allMatch = false
                    break
                }
            }
            
            if allMatch, let w = pastSets[index].weight, let r = pastSets[index].repetitions {
                return (w, r)
            }
        }
        return nil
    }
    
    /// Shared fetch for historical WorkoutExercises matching an exercise, excluding a specific workout.
    /// Results are sorted by workout start date descending (most recent first).
    static func fetchHistory(for exerciseID: UUID, excluding workoutID: UUID?, using context: ModelContext) -> [WorkoutExercise] {
        let descriptor = FetchDescriptor<WorkoutExercise>(
            predicate: #Predicate<WorkoutExercise> { we in
                we.exercise?.id == exerciseID && we.workout?.end != nil
            },
            sortBy: [SortDescriptor(\WorkoutExercise.workout?.start, order: .reverse)]
        )
        
        guard let results = try? context.fetch(descriptor) else { return [] }
        
        // Filter out current workout (can't use optional comparison in #Predicate)
        return results.filter { $0.workout?.id != workoutID }
    }
}

extension WorkoutExercise: Sortable {}
