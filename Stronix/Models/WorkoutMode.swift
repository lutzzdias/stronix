//
//  WorkoutMode.swift
//  Stronix
//

import Foundation

/// Determines whether the workout editor is tracking a live session or editing a historical one.
enum WorkoutMode {
    /// A new workout being tracked in real-time. Not yet persisted to SwiftData.
    case active
    /// An existing workout being edited. Already in the SwiftData context.
    case editing
}
