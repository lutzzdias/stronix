//
//  EquipmentSeederTests.swift
//  Stronix
//

import Testing
import SwiftData
@testable import Stronix

struct EquipmentSeederTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Exercise.self, Equipment.self, MuscleGroup.self, Workout.self, WorkoutExercise.self, WorkoutSet.self])
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    @Test
    func seedIfNeededInsertsFiveRecordsWhenEmpty() throws {
        let context = try makeContext()

        EquipmentSeeder.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<Equipment>())
        #expect(count == 5)
    }

    @Test
    func seedIfNeededDoesNothingWhenRecordsExist() throws {
        let context = try makeContext()
        context.insert(Equipment(name: "Custom", icon: "star"))
        try context.save()

        EquipmentSeeder.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<Equipment>())
        #expect(count == 1)
    }
}
