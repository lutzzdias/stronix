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

    // MARK: - totalVolume

    // These use completed sets so they hold regardless of which sets
    // `countsTowardVolume` admits.

    @Test func totalVolumeEmpty() {
        let workout = Workout()
        #expect(workout.totalVolume == 0)
    }

    @Test func totalVolumeCalculates() {
        let set1 = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let set2 = WorkoutSet(repetitions: 8, weight: 25, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2])
        let workout = Workout(exercises: [workoutExercise])

        // (20 * 10) + (25 * 8) = 200 + 200 = 400
        #expect(workout.totalVolume == 400)
    }

    @Test func totalVolumeWithNilValues() {
        let set1 = WorkoutSet(completed: true)
        let set2 = WorkoutSet(repetitions: 10, weight: nil, completed: true)
        let set3 = WorkoutSet(repetitions: nil, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2, set3])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.totalVolume == 0)
    }

    @Test func totalVolumeExcludesUncompletedSets() {
        let done = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let planned = WorkoutSet(repetitions: 10, weight: 100, completed: false)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [done, planned])
        let workout = Workout(exercises: [workoutExercise])

        // Only the completed set counts: 20 × 10 = 200, not 1200.
        #expect(workout.totalVolume == 200)
    }

    @Test func totalVolumeIsZeroWhenNothingCompleted() {
        let planned = WorkoutSet(repetitions: 10, weight: 20, completed: false)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [planned])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.totalVolume == 0)
    }

    @Test func totalVolumeIncludesWarmUpSets() {
        let warmUp = WorkoutSet(repetitions: 10, weight: 20, completed: true, tag: .warmUp)
        let working = WorkoutSet(repetitions: 5, weight: 40, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [warmUp, working])
        let workout = Workout(exercises: [workoutExercise])

        // (20 × 10) + (40 × 5) = 400 — warm-ups are not excluded.
        #expect(workout.totalVolume == 400)
    }

    // MARK: - hasCompletedSets

    @Test func hasCompletedSetsIsFalseWhenNoExercises() {
        let workout = Workout()
        #expect(workout.hasCompletedSets == false)
    }

    @Test func hasCompletedSetsIsFalseWhenExerciseHasNoSets() {
        let workoutExercise = WorkoutExercise(exercise: makeExercise())
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.hasCompletedSets == false)
    }

    @Test func hasCompletedSetsIsFalseWhenAllSetsAreUncompleted() {
        let set1 = WorkoutSet(repetitions: 10, weight: 20, completed: false)
        let set2 = WorkoutSet(repetitions: 8, weight: 25, completed: false)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.hasCompletedSets == false)
    }

    @Test func hasCompletedSetsIsTrueWhenAnySetIsCompleted() {
        let set1 = WorkoutSet(repetitions: 10, weight: 20, completed: false)
        let set2 = WorkoutSet(repetitions: 8, weight: 25, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set1, set2])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.hasCompletedSets == true)
    }

    @Test func hasCompletedSetsIsTrueWhenOnlyOneExerciseHasCompletedSet() {
        let uncompletedSet = WorkoutSet(completed: false)
        let completedSet = WorkoutSet(completed: true)
        let exerciseWithoutCompleted = WorkoutExercise(exercise: makeExercise(name: "A"), sets: [uncompletedSet])
        let exerciseWithCompleted = WorkoutExercise(exercise: makeExercise(name: "B"), sets: [completedSet])
        let workout = Workout(exercises: [exerciseWithoutCompleted, exerciseWithCompleted])

        #expect(workout.hasCompletedSets == true)
    }

    // MARK: - finish

    @Test func finishStampsEndTime() {
        let workout = Workout()
        #expect(workout.end == nil)
        workout.finish()
        #expect(workout.end != nil)
    }

    @Test func finishRemovesUncompletedSets() {
        let uncompletedSet = WorkoutSet(repetitions: 10, weight: 20, completed: false)
        let completedSet = WorkoutSet(repetitions: 8, weight: 25, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [uncompletedSet, completedSet])
        let workout = Workout(exercises: [workoutExercise])

        workout.finish()

        #expect(workoutExercise.sets.count == 1)
        #expect(workoutExercise.sets.first?.completed == true)
    }

    @Test func finishRemovesExercisesWithNoCompletedSets() {
        let uncompletedSet = WorkoutSet(completed: false)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [uncompletedSet])
        let workout = Workout(exercises: [workoutExercise])

        workout.finish()

        #expect(workout.workoutExercises.isEmpty)
    }

    @Test func finishNormalizesNilWeightOnCompletedSetToZero() {
        let completedSet = WorkoutSet(repetitions: 10, weight: nil, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(exercises: [workoutExercise])

        workout.finish()

        #expect(completedSet.weight == 0)
        #expect(completedSet.repetitions == 10)
    }

    @Test func finishNormalizesNilRepetitionsOnCompletedSetToZero() {
        let completedSet = WorkoutSet(repetitions: nil, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(exercises: [workoutExercise])

        workout.finish()

        #expect(completedSet.repetitions == 0)
        #expect(completedSet.weight == 20)
    }

    @Test func finishLeavesCompletedSetValuesUnchangedWhenAlreadyFilled() {
        let completedSet = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(exercises: [workoutExercise])

        workout.finish()

        #expect(completedSet.weight == 20)
        #expect(completedSet.repetitions == 10)
    }

    @Test func finishAutoGeneratesNameWhenEmpty() {
        let completedSet = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(name: "", exercises: [workoutExercise])

        workout.finish()

        #expect(workout.name.hasPrefix("Workout - "))
        #expect(workout.name.count > "Workout - ".count)
    }

    @Test func finishAutoGeneratesNameWhenWhitespaceOnly() {
        let completedSet = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(name: "   ", exercises: [workoutExercise])

        workout.finish()

        #expect(workout.name.hasPrefix("Workout - "))
    }

    @Test func finishPreservesNonEmptyName() {
        let completedSet = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(name: "Push Day", exercises: [workoutExercise])

        workout.finish()

        #expect(workout.name == "Push Day")
    }

    @Test func finishTrimsWhitespaceFromName() {
        let completedSet = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [completedSet])
        let workout = Workout(name: "  Leg Day  ", exercises: [workoutExercise])

        workout.finish()

        #expect(workout.name == "Leg Day")
    }

    // MARK: - shareText

    /// A workout with one exercise and a single 20 kg × 10 set.
    private func makeShareableWorkout() -> Workout {
        let set = WorkoutSet(repetitions: 10, weight: 20, completed: true)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(name: "Bench Press"), sets: [set])
        return Workout(name: "Push", exercises: [workoutExercise])
    }

    @Test func shareTextInKilograms() {
        let text = makeShareableWorkout().shareText(in: .kilograms)

        #expect(text.contains("Bench Press"))
        #expect(text.contains("20 kg × 10"))
        // Volume is load × reps: 20 × 10 = 200
        #expect(text.contains("Volume: 200 kg"))
    }

    @Test func shareTextInPounds() {
        let text = makeShareableWorkout().shareText(in: .pounds)

        #expect(text.contains("44 lbs × 10"))
        #expect(text.contains("Volume: 441 lbs"))
        #expect(!text.contains("kg"))
    }

    @Test func shareTextLabelsUnknownExercise() {
        let workout = makeShareableWorkout()
        workout.workoutExercises[0].exercise = nil

        #expect(workout.shareText(in: .kilograms).contains("Unknown"))
    }

    @Test func shareTextTreatsNilWeightAsZero() {
        let set = WorkoutSet(repetitions: 10, weight: nil)
        let workoutExercise = WorkoutExercise(exercise: makeExercise(), sets: [set])
        let workout = Workout(exercises: [workoutExercise])

        #expect(workout.shareText(in: .kilograms).contains("0 kg × 10"))
    }
}
