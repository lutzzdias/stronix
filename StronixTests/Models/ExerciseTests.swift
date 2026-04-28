//
//  ExerciseTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
import SwiftData
@testable import Stronix

struct ExerciseTests {
    
    @Test
    func initDefaults() {
        let exercise = Exercise(name: "Test")
        
        #expect(exercise.name == "Test")
        #expect(exercise.desc == nil)
        #expect(exercise.equipment == nil)
        #expect(exercise.muscle == nil)
        #expect(exercise.isArchived == false)
    }
    
    @Test
    func initWithAllValues() {
        let exercise = Exercise(
            name: "Test",
            desc: "Description",
            equipment: "Equipment",
            muscle: "Muscle",
        )
        
        #expect(exercise.name == "Test")
        #expect(exercise.desc == "Description")
        #expect(exercise.equipment == "Equipment")
        #expect(exercise.muscle == "Muscle")
        #expect(exercise.isArchived == false)
    }
    
    @Test
    func archiveExercise() {
        let exercise = Exercise(name: "Test")
        #expect(exercise.isArchived == false)
        exercise.isArchived.toggle()
        #expect(exercise.isArchived == true)
    }
}

// MARK: - Duplicate Name Validation

struct ExerciseDuplicateNameTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Exercise.self, configurations: config)
        return ModelContext(container)
    }

    @Test
    func uniqueNameSucceeds() throws {
        let context = try makeContext()
        let existing = Exercise(name: "Bench Press")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("Squat", in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func duplicateNameFails() throws {
        let context = try makeContext()
        let existing = Exercise(name: "Bench Press")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("Bench Press", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func caseInsensitiveDuplicateFails() throws {
        let context = try makeContext()
        let existing = Exercise(name: "Bench Press")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("bench press", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func whitespaceTrimmedDuplicateFails() throws {
        let context = try makeContext()
        let existing = Exercise(name: "Bench Press")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("  Bench Press  ", in: context)
        #expect(isDuplicate == true)
    }

    @Test
    func archivedExerciseDoesNotTriggerDuplicate() throws {
        let context = try makeContext()
        let archived = Exercise(name: "Bench Press")
        archived.isArchived = true
        context.insert(archived)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("Bench Press", in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func editingSameExerciseSucceeds() throws {
        let context = try makeContext()
        let existing = Exercise(name: "Bench Press")
        context.insert(existing)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("Bench Press", excludingID: existing.id, in: context)
        #expect(isDuplicate == false)
    }

    @Test
    func editingToMatchAnotherExerciseFails() throws {
        let context = try makeContext()
        let exerciseA = Exercise(name: "Bench Press")
        let exerciseB = Exercise(name: "Squat")
        context.insert(exerciseA)
        context.insert(exerciseB)
        try context.save()

        let isDuplicate = try Exercise.isDuplicateName("Bench Press", excludingID: exerciseB.id, in: context)
        #expect(isDuplicate == true)
    }
}
