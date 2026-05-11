//
//  EquipmentSeeder.swift
//  Stronix
//
//  Created by Thiago Dias on 11/05/26.
//

import Foundation
import SwiftData

enum EquipmentSeeder {
    static func seedIfNeeded(context: ModelContext) {
        let count = (try? context.fetchCount(FetchDescriptor<Equipment>())) ?? 0
        guard count == 0 else { return }

        let defaults: [(String, String)] = [
            ("Barbell", "figure.strengthtraining.traditional"),
            ("Dumbbell", "dumbbell.fill"),
            ("Machine", "gearshape.fill"),
            ("Cable", "cable.coaxial"),
            ("Bodyweight", "figure.walk"),
        ]

        for (name, icon) in defaults {
            context.insert(Equipment(name: name, icon: icon))
        }

        Log.persistence.info("Seeded default equipment")
    }
}
