//
//  WorkoutTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
import Foundation
@testable import Stronix

private let secondsPerMinute: TimeInterval = 60
private let secondsPerHour: TimeInterval = 3600

struct WorkoutTests {
    private func makeExercise(name: String = "Test") -> Exercise {
        Exercise(name: name)
    }

    // MARK: - init

    @Test func initDefaults() {
        let workout = Workout()
        #expect(workout.name == "")
        #expect(workout.comment == "")
        #expect(workout.end == nil)
        #expect(workout.workoutExercises.isEmpty)
    }

    @Test func initWithValues() {
        let end = Date.now
        let workout = Workout(name: "Push", comment: "Hard", end: end)
        #expect(workout.name == "Push")
        #expect(workout.comment == "Hard")
        #expect(workout.end == end)
    }

    // MARK: - exercises

    @Test func exercisesReturnsFromSortedWorkoutExercises() {
        let exercise1 = makeExercise(name: "A")
        let exercise2 = makeExercise(name: "B")
        let we1 = WorkoutExercise(exercise: exercise1, sortIndex: 1)
        let we2 = WorkoutExercise(exercise: exercise2, sortIndex: 0)
        let workout = Workout(exercises: [we1, we2])

        let exercises = workout.exercises
        #expect(exercises[0].name == "B")
        #expect(exercises[1].name == "A")
    }

    @Test func exercisesSkipsNilExercise() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        workoutExercise.exercise = nil
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.exercises.isEmpty)
    }

    // MARK: - sortedExercises

    @Test func sortedExercisesReturnsBySortIndex() {
        let we1 = WorkoutExercise(exercise: makeExercise(), sortIndex: 2)
        let we2 = WorkoutExercise(exercise: makeExercise(), sortIndex: 0)
        let we3 = WorkoutExercise(exercise: makeExercise(), sortIndex: 1)
        let workout = Workout(exercises: [we1, we2, we3])

        let sorted = workout.sortedExercises
        #expect(sorted[0].sortIndex == 0)
        #expect(sorted[1].sortIndex == 1)
        #expect(sorted[2].sortIndex == 2)
    }

    // MARK: - appendExercise

    @Test func appendExerciseAssignsSortIndexAndWorkout() {
        let workout = Workout()
        let we1 = WorkoutExercise(exercise: makeExercise())
        let we2 = WorkoutExercise(exercise: makeExercise())

        workout.appendExercise(we1)
        workout.appendExercise(we2)

        #expect(we1.sortIndex == 0)
        #expect(we2.sortIndex == 1)
        #expect(we1.workout === workout)
        #expect(we2.workout === workout)
        #expect(workout.workoutExercises.count == 2)
    }

    // MARK: - removeExercises

    @Test func removeExercisesRemovesAndReindexes() {
        let workout = Workout()
        let we1 = WorkoutExercise(exercise: makeExercise())
        let we2 = WorkoutExercise(exercise: makeExercise())
        let we3 = WorkoutExercise(exercise: makeExercise())
        workout.appendExercise(we1)
        workout.appendExercise(we2)
        workout.appendExercise(we3)

        workout.removeExercises(at: IndexSet(integer: 1))

        #expect(workout.workoutExercises.count == 2)
        #expect(workout.sortedExercises[0].id == we1.id)
        #expect(workout.sortedExercises[1].id == we3.id)
        #expect(workout.sortedExercises[0].sortIndex == 0)
        #expect(workout.sortedExercises[1].sortIndex == 1)
    }

    // MARK: - moveExercises

    @Test func moveExercisesReorders() {
        let workout = Workout()
        let we1 = WorkoutExercise(exercise: makeExercise())
        let we2 = WorkoutExercise(exercise: makeExercise())
        let we3 = WorkoutExercise(exercise: makeExercise())
        workout.appendExercise(we1)
        workout.appendExercise(we2)
        workout.appendExercise(we3)

        workout.moveExercises(from: IndexSet(integer: 2), to: 0)

        let sorted = workout.sortedExercises
        #expect(sorted[0].id == we3.id)
        #expect(sorted[1].id == we1.id)
        #expect(sorted[2].id == we2.id)
    }

    // MARK: - duration

    @Test func durationWithEnd() {
        let start = Date.now
        let end = start.addingTimeInterval(secondsPerHour)
        let workout = Workout(end: end)
        workout.start = start

        #expect(workout.duration == secondsPerHour)
    }

    @Test func durationWithoutEndUsesNow() {
        let workout = Workout()
        workout.start = Date.now.addingTimeInterval(-secondsPerMinute)

        #expect(workout.duration >= 59)
        #expect(workout.duration <= 62)
    }

    @Test func durationWithoutEndClampsToStart() {
        let workout = Workout()
        workout.start = Date.now.addingTimeInterval(secondsPerHour) // start in the future

        #expect(workout.duration >= 0)
    }

    // MARK: - numberOfSets

    @Test func numberOfSetsEmpty() {
        let workout = Workout()
        #expect(workout.numberOfSets == 0)
    }

    @Test func numberOfSetsCounts() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        workoutExercise.appendSet(WorkoutSet())
        workoutExercise.appendSet(WorkoutSet())
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.numberOfSets == 2)
    }

    // MARK: - totalWeight

    @Test func totalWeightEmpty() {
        let workout = Workout()
        #expect(workout.totalWeight == 0)
    }

    @Test func totalWeightCalculates() {
        let set1 = WorkoutSet(repetitions: 10, weight: 20)
        let set2 = WorkoutSet(repetitions: 8, weight: 25)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2])
        let workout = Workout(exercises: [workoutExercise])

        // (20 * 10) + (25 * 8) = 200 + 200 = 400
        #expect(workout.totalWeight == 400)
    }

    @Test func totalWeightWithNilValues() {
        let set1 = WorkoutSet()
        let set2 = WorkoutSet(repetitions: 10, weight: nil)
        let set3 = WorkoutSet(repetitions: nil, weight: 20)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2, set3])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.totalWeight == 0)
    }
}
