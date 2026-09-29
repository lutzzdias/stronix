//
//  SettingsView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI

struct SettingsView: View {
    /// Default rest timer duration in seconds, persisted via UserDefaults
    @AppStorage(RestTimer.defaultDurationKey) private var defaultRestDuration: Double = RestTimer.fallbackDuration
    
    /// Enables system sound effects (e.g. set completion). Default true.
    @AppStorage(SoundEffects.enabledKey) private var soundEffectsEnabled: Bool = true

    /// Unit weights are shown and entered in. Storage stays kilograms.
    @AppStorage(WeightUnit.storageKey) private var weightUnit: WeightUnit = .kilograms

    /// Options from 30s to 5min in 15s increments
    private static let durationOptions: [TimeInterval] = stride(from: 30, through: 300, by: 15).map { $0 }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Equipment") {
                    NavigationLink("Manage Equipment") {
                        EquipmentListView()
                    }
                }

                Section("Muscles") {
                    NavigationLink("Manage Muscles") {
                        MuscleGroupListView()
                    }
                }

                Section("Units") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.label).tag(unit)
                        }
                    }
                }

                Section("Rest Timer") {
                    Picker("Default Duration", selection: $defaultRestDuration) {
                        ForEach(Self.durationOptions, id: \.self) { seconds in
                            Text(AppFormatter.restTimer(seconds)).tag(seconds)
                        }
                    }
                }
                
                Section {
                    Toggle("Sound effects", isOn: $soundEffectsEnabled)
                } header: {
                    Text("Feedback")
                } footer: {
                    Text("Plays a short sound when you complete a set. Respects the silent switch.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
