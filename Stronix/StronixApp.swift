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
    @State private var errorHandler = ErrorHandler()
    
    var container: ModelContainer = {
        let schema = Schema([Exercise.self, WorkoutSet.self, Workout.self, WorkoutExercise.self])
        let config = ModelConfiguration(schema: schema)
        do {
            let container = try ModelContainer(for: schema, configurations: config)
            Log.persistence.info("ModelContainer created successfully")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(errorHandler)
        }
        .modelContainer(container)
    }
}
