//
//  WeightUnit.swift
//  Stronix
//

import Foundation

/// The unit weights are displayed and entered in.
///
/// Weights are always *stored* in kilograms on `WorkoutSet.weight`; this type
/// only governs presentation and input. Use `fromKilograms(_:)` when rendering a
/// stored value and `toKilograms(_:)` before writing user input back to the model.
///
/// The selection is persisted under `storageKey` and read via `@AppStorage` in
/// views. Models take the unit as a parameter instead, since they have no access
/// to the SwiftUI environment.
enum WeightUnit: String, Codable, CaseIterable {
    case kilograms = "kg"
    case pounds = "lbs"

    /// UserDefaults key holding the selection. Default: `.kilograms`.
    static let storageKey = "weightUnit"

    /// Reads the selected unit from the given defaults store.
    ///
    /// Defaults to `.kilograms` when the key is absent (first launch) or holds an
    /// unrecognized value. The `defaults` parameter is injectable for testing.
    static func current(defaults: UserDefaults = .standard) -> WeightUnit {
        guard let raw = defaults.string(forKey: storageKey),
              let unit = WeightUnit(rawValue: raw) else { return .kilograms }
        return unit
    }

    /// Short label shown next to a weight ("kg" / "lbs").
    var label: String { rawValue }

    /// The `Foundation` mass unit backing conversions.
    var unitMass: UnitMass {
        switch self {
        case .kilograms: .kilograms
        case .pounds: .pounds
        }
    }

    /// Increment used by `Dragger` when adjusting weight, sized to the plates
    /// commonly available in each system.
    var draggerStep: Double {
        switch self {
        case .kilograms: 2.5
        case .pounds: 5
        }
    }

    /// Smallest increment a displayed value is rounded to.
    ///
    /// Kilograms are shown as stored. Pounds round to the nearest half so
    /// converted metric history reads as `49.5` rather than `49.604620…`.
    private var displayPrecision: Double? {
        switch self {
        case .kilograms: nil
        case .pounds: 0.5
        }
    }

    /// Converts a stored kilogram value into this unit, rounded for display.
    func fromKilograms(_ kilograms: Double) -> Double {
        let converted = Measurement(value: kilograms, unit: UnitMass.kilograms)
            .converted(to: unitMass)
            .value
        guard let precision = displayPrecision else { return converted }
        return (converted / precision).rounded() * precision
    }

    /// Converts a value entered in this unit into kilograms for storage.
    func toKilograms(_ value: Double) -> Double {
        Measurement(value: value, unit: unitMass)
            .converted(to: UnitMass.kilograms)
            .value
    }
}
