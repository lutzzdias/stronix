//
//  TimerView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI

struct TimerView: View {
    let startDate: Date
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "clock")
                Text(startDate, style: .timer)
            }
            
            Spacer()
            
            // TODO: Add rest timer
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

#Preview {
    TimerView(startDate: Date.now)
}
