//
//  SettingsView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI

struct SettingsView: View {
    /// Default rest timer duration in seconds, persisted via UserDefaults
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Double = 90
    
    /// Options from 30s to 5min in 15s increments
    private static let durationOptions: [TimeInterval] = stride(from: 30, through: 300, by: 15).map { $0 }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rest Timer") {
                    Picker("Default Duration", selection: $defaultRestDuration) {
                        ForEach(Self.durationOptions, id: \.self) { seconds in
                            Text(AppFormatter.restTimer(seconds)).tag(seconds)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
