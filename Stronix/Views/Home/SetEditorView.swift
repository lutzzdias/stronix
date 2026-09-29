//
//  SetEditorView.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import SwiftUI

struct SetEditorView: View {
    enum Field: Hashable {
        case weight
        case reps
    }
    
    @Environment(RestTimer.self) var restTimer
    @AppStorage(RestTimer.defaultDurationKey) private var defaultRestDuration: Double = RestTimer.fallbackDuration
    @AppStorage(WeightUnit.storageKey) private var weightUnit: WeightUnit = .kilograms

    @Bindable var set: WorkoutSet
    let onComplete: (WorkoutSet?) -> Void
    
    @State private var isShowingDetails = false
    @State private var completionCount = 0
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Dragger(
                    unit: weightUnit.label,
                    value: Binding(
                        get: { set.weight.map(weightUnit.fromKilograms) },
                        set: { set.weight = $0.map(weightUnit.toKilograms) }
                    ),
                    step: weightUnit.draggerStep,
                    focus: $focusedField,
                    focusValue: .weight
                )
                
                Divider()
                    .frame(height: 44)
                
                Dragger(
                    unit: "reps",
                    value: Binding(
                        get: { set.repetitions.map(Double.init) },
                        set: { set.repetitions = $0.map(Int.init) }
                    ),
                    step: 1,
                    intOnly: true,
                    focus: $focusedField,
                    focusValue: .reps
                )
            }
            
            HStack {
                if set.completed {
                    Button {
                        uncompleteSet()
                    } label: {
                        Text("Uncomplete set").frame(maxWidth: .infinity).padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        completeSet()
                    } label: {
                        Text("Complete set").frame(maxWidth: .infinity).padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Button { isShowingDetails = true } label: {
                    Image(systemName: "tag")
                        .font(.title3)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .sensoryFeedback(.success, trigger: completionCount)
        .sheet(isPresented: $isShowingDetails) {
            SetDetailsSheet(set: set)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedField = .weight
                } label: {
                    Label("Weight", systemImage: "chevron.left")
                }
                .disabled(focusedField == .weight)
                
                Button {
                    focusedField = .reps
                } label: {
                    Label("Reps", systemImage: "chevron.right")
                }
                .labelStyle(.trailingIcon)
                .disabled(focusedField == .reps)
                
                Spacer()
                
                Button("Done") {
                    focusedField = nil
                }
                .fontWeight(.semibold)
            }
        }
    }
    
    /// Marks the current set as completed, starts the rest timer, fires
    /// feedback, dismisses the keyboard, and notifies the parent so it can
    /// advance selection to the next uncompleted set.
    private func completeSet() {
        set.completed = true
        restTimer.begin(duration: defaultRestDuration)
        completionCount += 1
        SoundEffects.playTink()
        focusedField = nil
        Log.persistence.debug("Set completed: \(set.weight ?? 0) kg * \(set.repetitions ?? 0) reps")
        onComplete(nil)
    }

    /// Reverts the set to uncompleted state.
    private func uncompleteSet() {
        set.completed = false
        focusedField = nil
        Log.persistence.debug("Set uncompleted: \(set.weight ?? 0) kg * \(set.repetitions ?? 0) reps")
    }
}

// MARK: - Trailing icon label style

/// A label style that mirrors `.titleAndIcon` but places the icon after
/// the title — used for the "Reps →" button on the keyboard toolbar.
private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}

private extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}
