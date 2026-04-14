//
//  ExerciseTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
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
