//
//  WorkoutExerciseTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
import Foundation
@testable import Stronix

struct WorkoutExerciseTests {
    private func makeExercise() -> Exercise {
        Exercise(name: "Test")
    }
    
    @Test
    func initDefaults() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        
        #expect(workoutExercise.comment == "")
        #expect(workoutExercise.sets.isEmpty)
        #expect(workoutExercise.sortIndex == 0)
        #expect(workoutExercise.exercise?.name == "Test")
    }
    
    @Test
    func sortedSetsReturnsByIndex() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        let set1 = WorkoutSet(sortIndex: 2)
        let set2 = WorkoutSet(sortIndex: 0)
        let set3 = WorkoutSet(sortIndex: 1)
        workoutExercise.sets = [set1, set2, set3]
        
        let sorted = workoutExercise.sortedSets
        
        #expect(sorted[0].sortIndex == 0)
        #expect(sorted[1].sortIndex == 1)
        #expect(sorted[2].sortIndex == 2)
    }
    
    @Test
    func appendSetAssignsSortIndex() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        
        var workoutSets = workoutExercise.sets
        #expect(workoutSets.isEmpty)
        
        let set1 = WorkoutSet()
        workoutExercise.appendSet(set1)
        
        workoutSets = workoutExercise.sets
        #expect(workoutSets.count == 1)
        #expect(workoutSets[0].sortIndex == 0)
    }
    
    @Test
    func removeSetsRemovesAndReorders() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        let set1 = WorkoutSet(sortIndex: 0)
        let set2 = WorkoutSet(sortIndex: 1)
        let set3 = WorkoutSet(sortIndex: 2)
        workoutExercise.sets = [set1, set2, set3]
        
        let removed = workoutExercise.removeSets(at: IndexSet(integer: 1))
        
        #expect(removed.count == 1)
        #expect(removed[0].id == set2.id)
        #expect(workoutExercise.sets.count == 2)
        #expect(workoutExercise.sortedSets[0].sortIndex == 0)
        #expect(workoutExercise.sortedSets[1].sortIndex == 1)
    }
    
    @Test
    func removeSetsMultipleIndices() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        let set1 = WorkoutSet(sortIndex: 0)
        let set2 = WorkoutSet(sortIndex: 1)
        let set3 = WorkoutSet(sortIndex: 2)
        workoutExercise.sets = [set1, set2, set3]
        
        let removed = workoutExercise.removeSets(at: IndexSet([0, 2]))
        
        #expect(removed.count == 2)
        #expect(workoutExercise.sets.count == 1)
        #expect(workoutExercise.sortedSets[0].sortIndex == 0)
    }
    
    @Test
    func moveSetsReorders() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        let set1 = WorkoutSet(sortIndex: 0)
        let set2 = WorkoutSet(sortIndex: 1)
        let set3 = WorkoutSet(sortIndex: 2)
        workoutExercise.sets = [set1, set2, set3]
        
        workoutExercise.moveSets(from: IndexSet(integer: 0), to: 3)
        
        let sorted = workoutExercise.sortedSets
        #expect(sorted[0].id == set2.id)
        #expect(sorted[1].id == set3.id)
        #expect(sorted[2].id == set1.id)
        
    }
}
