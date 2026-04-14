//
//  WorkoutSetTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
@testable import Stronix

struct WorkoutSetTests {
    
    @Test
    func initDefaults() {
        let set = WorkoutSet()
        
        #expect(set.repetitions == nil)
        #expect(set.weight == nil)
        #expect(set.completed == false)
        #expect(set.minTargetRepetitions == nil)
        #expect(set.maxTargetRepetitions == nil)
        #expect(set.tag == nil)
        #expect(set.comment == nil)
        #expect(set.sortIndex == 0)
    }
    
    @Test
    func initWithValues() {
        let set = WorkoutSet(
            repetitions: 10,
            weight: 50.0,
            completed: true,
            minTargetRepetitions: 8,
            maxTargetRepetitions: 12,
            tag: Tag.failure,
            comment: "Hard",
            sortIndex: 5
        )
        
        #expect(set.repetitions == 10)
        #expect(set.weight == 50.0)
        #expect(set.completed == true)
        #expect(set.minTargetRepetitions == 8)
        #expect(set.maxTargetRepetitions == 12)
        #expect(set.tag == .failure)
        #expect(set.comment == "Hard")
        #expect(set.sortIndex == 5)
    }
    
    @Test
    func conformsToSortable() {
        let set = WorkoutSet()
        set.sortIndex = 5
        
        #expect(set.sortIndex == 5)
    }
}
