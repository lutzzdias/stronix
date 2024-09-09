//
//  StronixApp.swift
//  Stronix
//
//  Created by Thiago Dias on 10/08/24.
//

import SwiftUI
import SwiftData

@main
struct StronixApp: App {
    var container: ModelContainer = {
        let schema = Schema([Exercise.self, WorkoutSet.self, Workout.self, WorkoutExercise.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
