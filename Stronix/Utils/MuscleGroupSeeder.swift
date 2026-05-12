//
//  MuscleGroupSeeder.swift
//  Stronix
//

import Foundation
import SwiftData

enum MuscleGroupSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<MuscleGroup>())) ?? 0
        guard count == 0 else { return }

        let defaults: [String] = [
            "Chest",
            "Back",
            "Shoulders",
            "Arms",
            "Legs",
            "Core",
        ]

        for name in defaults {
            context.insert(MuscleGroup(name: name))
        }

        Log.persistence.info("Seeded default muscle groups")
    }
}
