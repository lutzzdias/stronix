//
//  SetDetailsSheet.swift
//  Stronix
//

import SwiftUI

struct SetDetailsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var set: WorkoutSet
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Comment") {
                    TextField("Add a note...", text: Binding(
                        get: { set.comment ?? "" },
                        set: { set.comment = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }
                
                Section {
                    Picker("Tag", selection: $set.tag) {
                        Text("Warm Up").tag(Tag?.some(.warmUp))
                        Text("Drop Set").tag(Tag?.some(.drop))
                        Text("Failure").tag(Tag?.some(.failure))
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    HStack {
                        Text("Tag")
                        Spacer()
                        if set.tag != nil {
                            Button("Clear") { set.tag = nil }
                                .font(.caption)
                                .textCase(nil)
                        }
                    }
                }
                
                Section {
                    Picker("Rate of Perceived Exertion", selection: $set.rpe) {
                        ForEach(RPE.allCases, id: \.self) { rpe in
                            HStack {
                                Text(rpe.label).bold()
                                Text(rpe.description).foregroundStyle(.secondary)
                            }
                            .tag(RPE?.some(rpe))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    HStack {
                        Text("RPE")
                        Spacer()
                        if set.rpe != nil {
                            Button("Clear") { set.rpe = nil }
                                .font(.caption)
                                .textCase(nil)
                        }
                    }
                }
            }
            .navigationTitle("Set Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
