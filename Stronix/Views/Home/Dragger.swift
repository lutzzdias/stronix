//
//  Dragger.swift
//  Stronix
//

import SwiftUI

/// A number input that supports both keyboard typing and vertical drag to adjust.
/// Drag the handle icon to adjust. Tap the value to edit via keyboard.
///
/// The control is generic over a `FocusValue` so the parent view can manage
/// keyboard focus across multiple Draggers (e.g. to drive a `.toolbar(placement: .keyboard)`
/// accessory bar). Pass a `FocusState<Value?>.Binding` and the specific
/// enum case this Dragger represents.
struct Dragger<FocusValue: Hashable>: View {
    let unit: String
    @Binding var value: Double?
    var step: Double = 1
    var intOnly: Bool = false
    var focus: FocusState<FocusValue?>.Binding
    var focusValue: FocusValue
    
    @State private var lastTranslation: Double = 0
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var boundaryHitCount: Int = 0
    @State private var didHitBoundaryThisDrag = false
    
    private let pointsPerStep: Double = 10
    private let maxHandleOffset: CGFloat = 3
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                TextField("–", value: $value, format: intOnly ? .number.precision(.fractionLength(0)) : .number)
                    .keyboardType(intOnly ? .numberPad : .decimalPad)
                    .focused(focus, equals: focusValue)
                    .fixedSize()
                
                Text(unit)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "line.horizontal.3")
                .font(.title2)
                .foregroundStyle(isDragging ? .primary : .secondary)
                .offset(y: dragOffset)
                .animation(.interactiveSpring, value: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            focus.wrappedValue = nil
                            isDragging = true
                            
                            // Animate handle in drag direction, capped
                            let raw = -gesture.translation.height
                            dragOffset = min(maxHandleOffset, max(-maxHandleOffset, -raw * 0.1))
                            
                            let delta = raw - lastTranslation
                            let steps = (delta / pointsPerStep).rounded(.towardZero)
                            if steps != 0 {
                                lastTranslation += steps * pointsPerStep
                                let result = DraggerStepper.step(
                                    from: value ?? 0,
                                    steps: steps,
                                    step: step
                                )
                                if result.didHitFloor && !didHitBoundaryThisDrag {
                                    didHitBoundaryThisDrag = true
                                    boundaryHitCount += 1
                                }
                                value = result.value
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            dragOffset = 0
                            lastTranslation = 0
                            didHitBoundaryThisDrag = false
                        }
                )
                .sensoryFeedback(.selection, trigger: value)
                .sensoryFeedback(.error, trigger: boundaryHitCount)
        }
    }
}

// MARK: - Step math

/// Pure helpers for `Dragger`'s per-step math.
///
/// Extracted to a non-generic namespace so the boundary-detection logic
/// can be unit-tested without committing to a specific `FocusValue` type.
enum DraggerStepper {
    /// Applies a signed step delta to `current` and clamps the result at
    /// the minimum boundary (0).
    ///
    /// - Parameters:
    ///   - current: The current value before applying the step.
    ///   - steps: Number of steps to apply. Can be negative.
    ///   - step: Size of a single step in value units.
    /// - Returns: A tuple of the clamped value and whether the requested
    ///   target was below the floor (i.e. boundary was hit this call).
    static func step(
        from current: Double,
        steps: Double,
        step: Double
    ) -> (value: Double, didHitFloor: Bool) {
        let target = current + steps * step
        let clamped = max(0, target)
        return (clamped, target < 0)
    }
}
