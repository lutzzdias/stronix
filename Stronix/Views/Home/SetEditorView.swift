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
                Dragger(
                    unit: "kg",
                    value: $set.weight,
                    step: 2.5
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
                    intOnly: true
                )
            }
            
            HStack {
                Button {
                    set.completed = true
                    restTimer.begin(duration: defaultRestDuration)
                    Log.persistence.debug("Set completed: \(set.weight ?? 0)kg * \(set.repetitions ?? 0) reps")
                    onComplete(nil)
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
        .sheet(isPresented: $isShowingDetails) {
            SetDetailsSheet(set: set)
        }
    }
}
