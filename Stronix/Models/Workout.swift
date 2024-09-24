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
    var exercises: [WorkoutExercise]
    // var routineId: UUID TODO: create routines
    
    init(name: String = "", comment: String = "", end: Date? = nil, exercises: [WorkoutExercise] = []) {
        self.id = UUID()
        self.start = Date.now
        
        self.name = name
        self.comment = comment
        self.end = end
        self.exercises = exercises
    }
    
    @Transient
    let timerFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.hour, .minute] // Specify which units to show
        formatter.unitsStyle = .abbreviated // Use abbreviated style for "h" and "m"
        formatter.zeroFormattingBehavior = .dropAll // Drop zero units (e.g., "0h" or "0m")
        
        return formatter
    }()
    
    var duration: TimeInterval {
        let e = end ?? max(start, Date.now)
        return e.timeIntervalSince(start)
    }
    
    var durationStr: String {
        timerFormatter.string(from: duration) ?? ""
    }
    
    @Transient
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy 'at' HH:mm"
        return formatter
    }()
    
    var date: String {
        return dateFormatter.string(from: start)
    }
    
    var numberOfSets: Int {
        exercises.reduce(0) { result, workoutExercise in
                result + workoutExercise.sets.count
        }
    }
    
    var totalWeight: Double {
        return exercises.reduce(0) { result, workoutExercise in
            result + workoutExercise.sets.reduce(0) { result, set in
                result + set.weight
            }
        }
    }
    
    // TODO: validate nil data
}
