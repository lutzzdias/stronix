//
//  SetEditorView.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import SwiftUI

struct SetEditorView: View {
    @Environment(RestTimer.self) var restTimer
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Double = 90
    
    @Bindable var set: WorkoutSet
    let onComplete: (WorkoutSet?) -> Void
    
    @State private var isShowingDetails = false
    
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
            
            HStack {
                Button("Complete set") {
                    set.completed = true
                    restTimer.begin(duration: defaultRestDuration)
                    Log.persistence.debug("Set completed: \(set.weight ?? 0)kg * \(set.repetitions ?? 0) reps")
                    onComplete(nil)
                }
                
                Spacer()
                
                Button { isShowingDetails = true } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $isShowingDetails) {
            SetDetailsSheet(set: set)
        }
    }
}
