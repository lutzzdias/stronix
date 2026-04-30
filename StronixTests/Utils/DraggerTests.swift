//
//  DraggerTests.swift
//  Stronix
//

import Testing
@testable import Stronix

/// Tests for `DraggerStepper.step(from:steps:step:)` — the pure per-step math
/// extracted from the Dragger drag gesture.
///
/// The gesture itself (SwiftUI `DragGesture`) is not covered here. These
/// tests lock down the boundary detection used to drive US-57's
/// once-per-drag error haptic.
struct DraggerTests {
    
    // MARK: - positive stepping
    
    @Test
    func incrementBySingleStep() {
        let result = DraggerStepper.step(from: 80, steps: 1, step: 2.5)
        #expect(result.value == 82.5)
        #expect(result.didHitFloor == false)
    }
    
    @Test
    func incrementByMultipleSteps() {
        let result = DraggerStepper.step(from: 10, steps: 4, step: 1)
        #expect(result.value == 14)
        #expect(result.didHitFloor == false)
    }
    
    @Test
    func fractionalStepSize() {
        let result = DraggerStepper.step(from: 20, steps: 3, step: 2.5)
        #expect(result.value == 27.5)
        #expect(result.didHitFloor == false)
    }
    
    // MARK: - negative stepping, no clamp
    
    @Test
    func decrementWithoutHittingFloor() {
        let result = DraggerStepper.step(from: 80, steps: -2, step: 2.5)
        #expect(result.value == 75)
        #expect(result.didHitFloor == false)
    }
    
    @Test
    func decrementExactlyToZeroDoesNotTripFloor() {
        // Landing exactly on 0 is a valid value, not a clamp event.
        let result = DraggerStepper.step(from: 2.5, steps: -1, step: 2.5)
        #expect(result.value == 0)
        #expect(result.didHitFloor == false)
    }
    
    // MARK: - floor clamping
    
    @Test
    func clampsBelowZero() {
        let result = DraggerStepper.step(from: 1, steps: -2, step: 2.5)
        #expect(result.value == 0)
        #expect(result.didHitFloor == true)
    }
    
    @Test
    func clampsFromZeroOnFurtherDecrement() {
        let result = DraggerStepper.step(from: 0, steps: -1, step: 1)
        #expect(result.value == 0)
        #expect(result.didHitFloor == true)
    }
    
    @Test
    func clampsLargeNegativeSteps() {
        let result = DraggerStepper.step(from: 5, steps: -100, step: 1)
        #expect(result.value == 0)
        #expect(result.didHitFloor == true)
    }
    
    // MARK: - identity
    
    @Test
    func zeroStepsIsIdentity() {
        let result = DraggerStepper.step(from: 42, steps: 0, step: 2.5)
        #expect(result.value == 42)
        #expect(result.didHitFloor == false)
    }
}
