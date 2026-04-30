//
//  TimerView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI

struct TimerView: View {
    @Environment(RestTimer.self) var restTimer
    
    @State private var showRestTimerSheet = false
    
    let startDate: Date
    
    var body: some View {
        // re-render view every second (rest timer)
        let _ = restTimer.tick
        
        HStack {
            HStack {
                Image(systemName: "clock")
                Text(startDate, style: .timer)
            }
            
            Spacer()
            
            Button {
                showRestTimerSheet = true
            } label: {
                HStack {
                    Image(systemName: "timer")
                    if restTimer.isRunning {
                        Text(AppFormatter.restTimer(restTimer.remainingTime))
                            .monospacedDigit()
                    }
                }
                .foregroundStyle(restTimer.remainingTime < 0 && restTimer.isRunning ? .red : .accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .sheet(isPresented: $showRestTimerSheet) {
            RestTimerSheet()
        }
        .sensoryFeedback(.success, trigger: restTimer.expired)
    }
}

#Preview {
    TimerView(startDate: Date.now)
        .environment(RestTimer())
}
