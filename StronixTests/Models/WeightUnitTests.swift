//
//  WeightUnitTests.swift
//  Stronix
//

import Testing
import Foundation
@testable import Stronix

/// Tests for `WeightUnit` conversion, display rounding, and defaults reading.
///
/// Uses an isolated `UserDefaults(suiteName:)` so tests do not mutate the app's
/// persistent defaults.
struct WeightUnitTests {
    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "com.stronix.tests.WeightUnit.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    /// Tolerance for float comparisons on unrounded conversions.
    private let epsilon = 0.0001

    // MARK: - current(defaults:)

    @Test
    func defaultsToKilogramsWhenKeyAbsent() {
        let defaults = makeIsolatedDefaults()
        #expect(WeightUnit.current(defaults: defaults) == .kilograms)
    }

    @Test
    func readsStoredSelection() {
        let defaults = makeIsolatedDefaults()
        defaults.set(WeightUnit.pounds.rawValue, forKey: WeightUnit.storageKey)
        #expect(WeightUnit.current(defaults: defaults) == .pounds)
    }

    @Test
    func fallsBackToKilogramsOnUnrecognizedValue() {
        let defaults = makeIsolatedDefaults()
        defaults.set("stones", forKey: WeightUnit.storageKey)
        #expect(WeightUnit.current(defaults: defaults) == .kilograms)
    }

    @Test
    func storageKeyIsStable() {
        // Guards against a rename silently resetting users' unit choice.
        // The key is also referenced by @AppStorage across the views.
        #expect(WeightUnit.storageKey == "weightUnit")
    }

    // MARK: - Labels and steps

    @Test
    func labelsMatchRawValues() {
        #expect(WeightUnit.kilograms.label == "kg")
        #expect(WeightUnit.pounds.label == "lbs")
    }

    @Test
    func draggerStepPerUnit() {
        #expect(WeightUnit.kilograms.draggerStep == 2.5)
        #expect(WeightUnit.pounds.draggerStep == 5)
    }

    // MARK: - Kilograms are a no-op

    @Test
    func kilogramsConvertUnchanged() {
        #expect(WeightUnit.kilograms.fromKilograms(22.5) == 22.5)
        #expect(WeightUnit.kilograms.toKilograms(22.5) == 22.5)
    }

    @Test
    func kilogramsDoNotRound() {
        // kg is shown as stored, so an odd stored value must survive display.
        #expect(WeightUnit.kilograms.fromKilograms(22.3456) == 22.3456)
    }

    // MARK: - Pounds conversion

    @Test
    func poundsFromKilogramsRoundsToNearestHalf() {
        // 22.5 kg == 49.6040 lbs exactly, displayed as 49.5.
        #expect(WeightUnit.pounds.fromKilograms(22.5) == 49.5)
    }

    @Test
    func poundsToKilogramsIsExact() {
        // 45 lbs == 20.41165665 kg; input is stored unrounded.
        let kilograms = WeightUnit.pounds.toKilograms(45)
        #expect(abs(kilograms - 20.41165665) < epsilon)
    }

    @Test
    func poundsRoundTripIsStableForEnteredValues() {
        // A value the user typed in lbs must read back as the same number.
        for entered in [5.0, 45.0, 50.0, 135.0, 225.0] {
            let stored = WeightUnit.pounds.toKilograms(entered)
            #expect(WeightUnit.pounds.fromKilograms(stored) == entered)
        }
    }

    @Test
    func zeroConvertsToZero() {
        #expect(WeightUnit.pounds.fromKilograms(0) == 0)
        #expect(WeightUnit.pounds.toKilograms(0) == 0)
    }
}
