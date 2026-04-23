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
    var comment: String
    var start: Date
    var end: Date?
    
    @Relationship(deleteRule: .cascade)
    var workoutExercises: [WorkoutExercise]
    // var routineId: UUID TODO: create routines
    
    init(name: String = "", comment: String = "", end: Date? = nil, exercises: [WorkoutExercise] = []) {
        self.id = UUID()
        self.start = Date.now
        
        self.name = name
        self.comment = comment
        self.end = end
        self.workoutExercises = exercises
    }
    
    var exercises: [Exercise] {
        sortedExercises.compactMap { workoutExercise in workoutExercise.exercise }
    }
    
    var sortedExercises: [WorkoutExercise] {
        workoutExercises.sorted { left, right in left.sortIndex < right.sortIndex }
    }
    
    func appendExercise(_ exercise: WorkoutExercise) {
        exercise.sortIndex = workoutExercises.count
        exercise.workout = self
        workoutExercises.append(exercise)
    }
    
    func removeExercises(at offsets: IndexSet) {
        let sorted = sortedExercises
        for index in offsets {
            workoutExercises.removeAll { exercise in exercise.id == sorted[index].id }
        }
        for (index, exercise) in sortedExercises.enumerated() {
            exercise.sortIndex = index
        }
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        var ordered = sortedExercises
        ordered.move(fromOffsets: source, toOffset: destination)
        ordered.reorder()
    }
    
    var duration: TimeInterval {
        let e = end ?? max(start, Date.now)
        return e.timeIntervalSince(start)
    }
    
    var numberOfSets: Int {
        workoutExercises.reduce(0) { result, workoutExercise in
                result + workoutExercise.sets.count
        }
    }
    
    var totalWeight: Double {
        return workoutExercises.reduce(0) { result, workoutExercise in
            result + workoutExercise.sets.reduce(0) { exerciseTotalWeight, set in
                exerciseTotalWeight + ((set.weight ?? 0) * Double(set.repetitions ?? 0))
            }
        }
    }
    
    /// Finalizes the workout by removing uncompleted sets and empty exercises, then stamps the end time.
    func finish() {
        for exercise in workoutExercises {
            // Remove sets that were never completed
            let uncompleted = exercise.sortedSets.enumerated()
                .filter { !$0.element.completed }
                .map { $0.offset }
            if !uncompleted.isEmpty {
                _ = exercise.removeSets(at: IndexSet(uncompleted))
            }
        }
        // Remove exercises left with zero sets after cleanup
        workoutExercises.removeAll { $0.sets.isEmpty }
        sortedExercises.reorder()
        end = Date.now
    }
    
    /// Plain text summary suitable for sharing.
    var shareText: String {
        var lines: [String] = []
        lines.append(AppFormatter.date(start))
        lines.append("Duration: \(AppFormatter.duration(duration))")
        lines.append("Total weight: \(String(format: "%g", totalWeight)) kg")
        lines.append("")
        for exercise in sortedExercises {
            lines.append(exercise.exercise?.name ?? "Unknown")
            for set in exercise.sortedSets {
                let w = String(format: "%g", set.weight ?? 0)
                let r = set.repetitions ?? 0
                lines.append("  \(w) kg × \(r)")
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
    
    // TODO: validate nil data
}
