//
//  MuscleGroupTests.swift
//  Stronix
//

import Testing
import SwiftData
@testable import Stronix

struct MuscleGroupTests {

    @Test
    func initDefaults() {
        let muscleGroup = MuscleGroup(name: "Chest")

        #expect(muscleGroup.name == "Chest")
        #expect(muscleGroup.desc == nil)
        #expect(muscleGroup.primaryExercises.isEmpty)
        #expect(muscleGroup.secondaryExercises.isEmpty)
    }

    @Test
    func initWithDescription() {
        let muscleGroup = MuscleGroup(name: "Chest", desc: "Pectoral muscles")

        #expect(muscleGroup.name == "Chest")
        #expect(muscleGroup.desc == "Pectoral muscles")
    }
}

// MARK: - Duplicate Name Validation

struct MuscleGroupDuplicateNameTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Exercise.self, Equipment.self, MuscleGroup.self, Workout.self, WorkoutExercise.self, WorkoutSet.self])
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    @Test
    func uniqueNameSucceeds() throws {
        let context = try makeContext()
        let existing = MuscleGroup(name: "Chest")
        context.insert(existing)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("Back", in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func duplicateNameFails() throws {
        let context = try makeContext()
        let existing = MuscleGroup(name: "Chest")
        context.insert(existing)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("Chest", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func caseInsensitiveDuplicateFails() throws {
        let context = try makeContext()
        let existing = MuscleGroup(name: "Chest")
        context.insert(existing)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("chest", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func whitespaceTrimmedDuplicateFails() throws {
        let context = try makeContext()
        let existing = MuscleGroup(name: "Chest")
        context.insert(existing)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("  Chest  ", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func excludingIDAllowsSameNameForSelf() throws {
        let context = try makeContext()
        let existing = MuscleGroup(name: "Chest")
        context.insert(existing)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("Chest", excludingID: existing.id, in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func excludingIDStillDetectsDuplicateWithOtherRecord() throws {
        let context = try makeContext()
        let groupA = MuscleGroup(name: "Chest")
        let groupB = MuscleGroup(name: "Back")
        context.insert(groupA)
        context.insert(groupB)
        try context.save()

        let isDuplicate = try MuscleGroup.isDuplicateName("Chest", excludingID: groupB.id, in: context)
        #expect(isDuplicate == true)
    }
}
