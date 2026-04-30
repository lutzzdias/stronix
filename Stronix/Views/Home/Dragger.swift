//
//  Dragger.swift
//  Stronix
//

import SwiftUI

/// A number input that supports both keyboard typing and vertical drag to adjust.
/// Drag the handle icon to adjust. Tap the value to edit via keyboard.
struct Dragger: View {
    let unit: String
    @Binding var value: Double?
    var step: Double = 1
    var intOnly: Bool = false
    
    @State private var lastTranslation: Double = 0
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var boundaryHitCount: Int = 0
    @State private var didHitBoundaryThisDrag = false
    @FocusState private var isFocused: Bool
    
    private let pointsPerStep: Double = 10
    private let maxHandleOffset: CGFloat = 3
    
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                TextField("–", value: $value, format: intOnly ? .number.precision(.fractionLength(0)) : .number)
                    .keyboardType(intOnly ? .numberPad : .decimalPad)
                    .focused($isFocused)
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
                            isFocused = false
                            isDragging = true
                            
                            // Animate handle in drag direction, capped
                            let raw = -gesture.translation.height
                            dragOffset = min(maxHandleOffset, max(-maxHandleOffset, -raw * 0.1))
                            
                            let delta = raw - lastTranslation
                            let steps = (delta / pointsPerStep).rounded(.towardZero)
                            if steps != 0 {
                                lastTranslation += steps * pointsPerStep
                                let result = Dragger.step(
                                    from: value ?? 0,
                                    steps: steps,
                                    step: step
                                )
                                // Fire boundary haptic once per drag when we hit the floor
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

extension Dragger {
    /// Pure helper that applies a signed step delta to `current` and clamps the
    /// result at the minimum boundary (0).
    ///
    /// Extracted from the drag gesture handler so the boundary detection
    /// logic can be unit-tested without driving SwiftUI gestures.
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
