//
//  SetEditorView.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import SwiftUI

struct SetEditorView: View {
    @Environment(RestTimer.self) var restTimer
    
    @Bindable var set: WorkoutSet
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                HStack {
                    TextField("Weight", value: $set.weight, format: .number)
                        .keyboardType(.decimalPad)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 44)
                
                HStack {
                    TextField("Reps", value: $set.repetitions, format: .number)
                        .keyboardType(.numberPad)
                    Text("reps")
                        .foregroundStyle(.secondary)
                }
            }
            
            Button("Complete set") {
                set.completed = true
                restTimer.begin(duration: RestTimer.presets[0]) // TODO: get from config
                Log.persistence.debug("Set completed: \(set.weight ?? 0)kg * \(set.repetitions ?? 0) reps")
                onComplete()
            }
        }
        .padding(.horizontal)
    }
}
