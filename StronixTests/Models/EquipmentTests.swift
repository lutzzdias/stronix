//
//  EquipmentTests.swift
//  Stronix
//

import Testing
import Foundation
import SwiftData
@testable import Stronix

struct EquipmentTests {

    @Test
    func initDefaults() {
        let equipment = Equipment(name: "Barbell", icon: "dumbbell.fill")

        #expect(equipment.name == "Barbell")
        #expect(equipment.icon == "dumbbell.fill")
        #expect(equipment.id != UUID())
    }
}

// MARK: - Duplicate Name Validation

struct EquipmentDuplicateNameTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Exercise.self, Equipment.self, MuscleGroup.self, Workout.self, WorkoutExercise.self, WorkoutSet.self])
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    @Test
    func uniqueNameSucceeds() throws {
        let context = try makeContext()
        let existing = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("Dumbbell", in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func duplicateNameFails() throws {
        let context = try makeContext()
        let existing = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("Barbell", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func caseInsensitiveDuplicateFails() throws {
        let context = try makeContext()
        let existing = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("barbell", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func whitespaceTrimmedDuplicateFails() throws {
        let context = try makeContext()
        let existing = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("  Barbell  ", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func excludingIDAllowsSameNameForSelf() throws {
        let context = try makeContext()
        let existing = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("Barbell", excludingID: existing.id, in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func excludingIDStillDetectsDuplicateWithOtherRecord() throws {
        let context = try makeContext()
        let equipmentA = Equipment(name: "Barbell", icon: "figure.strengthtraining.traditional")
        let equipmentB = Equipment(name: "Dumbbell", icon: "dumbbell.fill")
        context.insert(equipmentA)
        context.insert(equipmentB)
        try context.save()

        let isDuplicate = try Equipment.isDuplicateName("Barbell", excludingID: equipmentB.id, in: context)
        #expect(isDuplicate == true)
    }
}
