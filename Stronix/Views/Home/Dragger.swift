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
                                value = max(0, (value ?? 0) + steps * step)
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            dragOffset = 0
                            lastTranslation = 0
                        }
                )
                .sensoryFeedback(.selection, trigger: value)
        }
    }
}
