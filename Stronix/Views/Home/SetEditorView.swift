//
//  SetEditorView.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import SwiftUI

struct SetEditorView: View {
    /// Keyboard-focusable fields in this editor. Drives both `@FocusState`
    /// and the directional keyboard-toolbar buttons (US-41).
    enum Field: Hashable {
        case weight
        case reps
    }
    
    @Environment(RestTimer.self) var restTimer
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Double = 90
    
    @Bindable var set: WorkoutSet
    let onComplete: (WorkoutSet?) -> Void
    
    @State private var isShowingDetails = false
    @State private var completionCount = 0
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Dragger(
                    unit: "kg",
                    value: $set.weight,
                    step: 2.5,
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
                Button {
                    completeSet()
                } label: {
                    Text("Complete set").frame(maxWidth: .infinity).padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                
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
            // Keyboard accessory toolbar (US-41): jump between Weight and Reps
            // fields or dismiss the keyboard. Completing the set is handled
            // by the main "Complete set" button below the editor.
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
    ///
    /// Shared between the main "Complete set" button and the keyboard
    /// toolbar's ✓ Complete action.
    private func completeSet() {
        set.completed = true
        restTimer.begin(duration: defaultRestDuration)
        completionCount += 1
        SoundEffects.playTink()
        focusedField = nil
        Log.persistence.debug("Set completed: \(set.weight ?? 0)kg * \(set.repetitions ?? 0) reps")
        onComplete(nil)
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
