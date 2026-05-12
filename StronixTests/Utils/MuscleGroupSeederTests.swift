//
//  MuscleGroupSeederTests.swift
//  Stronix
//

import Testing
import SwiftData
@testable import Stronix

struct MuscleGroupSeederTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Exercise.self, Equipment.self, MuscleGroup.self, Workout.self, WorkoutExercise.self, WorkoutSet.self])
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    @Test
    func seedIfNeededInsertsSixRecordsWhenEmpty() throws {
        let context = try makeContext()

        MuscleGroupSeeder.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<MuscleGroup>())
        #expect(count == 6)
    }

    @Test
    func seedIfNeededDoesNothingWhenRecordsExist() throws {
        let context = try makeContext()
        context.insert(MuscleGroup(name: "Custom"))
        try context.save()

        MuscleGroupSeeder.seedIfNeeded(context: context)

        let count = try context.fetchCount(FetchDescriptor<MuscleGroup>())
        #expect(count == 1)
    }
}
