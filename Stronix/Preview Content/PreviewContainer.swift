//
//  PreviewContainer.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: Exercise.self, Set.self, Workout.self, WorkoutExercise.self,
                                           configurations: .init(isStoredInMemoryOnly: true))
        
        // insert sample exercises
        for exercise in Exercise.sampleData {
            container.mainContext.insert(exercise)
        }

        return container
    } catch {
        fatalError("Failed to create container")
    }
}()
