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
    
    // TODO: validate nil data
}
