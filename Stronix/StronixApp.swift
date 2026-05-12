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
    @State private var restTimer = RestTimer()
    
    var container: ModelContainer = {
        let schema = Schema([Exercise.self, WorkoutSet.self, Workout.self, WorkoutExercise.self, Equipment.self, MuscleGroup.self])
        let config = ModelConfiguration(schema: schema)
        do {
            let container = try ModelContainer(for: schema, configurations: config)
            Log.persistence.info("ModelContainer created successfully")
            EquipmentSeeder.seedIfNeeded(context: container.mainContext)
            MuscleGroupSeeder.seedIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(errorHandler)
                .environment(restTimer)
        }
        .modelContainer(container)
    }
}
