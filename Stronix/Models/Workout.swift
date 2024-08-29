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
    var desc: String
    var start: Date
    var end: Date?
    
    @Relationship(deleteRule: .cascade)
    var exercises: [WorkoutExercise]
    // var routineId: UUID TODO: create routines
    
    init(name: String = "", desc: String = "", end: Date? = nil, exercises: [WorkoutExercise] = []) {
        self.id = UUID()
        self.start = Date.now
        
        self.name = name
        self.desc = desc
        self.end = end
        self.exercises = exercises
    }
    
    @Transient
    let timerFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
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
    
    // TODO: number of sets completed
    
    // TODO: total weight lifted
    
    // TODO: validate nil data
}
