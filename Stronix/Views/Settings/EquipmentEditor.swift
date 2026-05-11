//
//  EquipmentEditor.swift
//  Stronix
//
//  Created by Thiago Dias on 11/05/26.
//

import SwiftUI
import SwiftData

struct EquipmentEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(ErrorHandler.self) var errorHandler

    let equipment: Equipment?

    private var editorTitle: String {
        equipment == nil ? "Add Equipment" : "Edit Equipment"
    }

    @State private var name: String = ""
    @State private var icon: String = "figure.strengthtraining.traditional"
    @State private var isDuplicate: Bool = false

    private static let availableIcons: [(symbol: String, label: String)] = [
        ("figure.strengthtraining.traditional", "Barbell"),
        ("dumbbell.fill", "Dumbbell"),
        ("gearshape.fill", "Machine"),
        ("cable.coaxial", "Cable"),
        ("figure.walk", "Bodyweight"),
        ("figure.run", "Cardio"),
        ("figure.flexibility", "Stretch"),
        ("sportscourt.fill", "Court"),
        ("bolt.fill", "Power"),
        ("hands.clap.fill", "Bands"),
    ]

    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Self.availableIcons, id: \.symbol) { item in
                            VStack(spacing: 4) {
                                Image(systemName: item.symbol)
                                    .font(.title2)
                                Text(item.label)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(icon == item.symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(icon == item.symbol ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                icon = item.symbol
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            if errorHandler.message == nil { dismiss() }
                        }
                    }.disabled(isDisabled())
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
            }
            .onAppear {
                if let equipment {
                    name = equipment.name
                    icon = equipment.icon
                }
                checkDuplicate(name)
            }
            .onChange(of: name) { _, newValue in
                checkDuplicate(newValue)
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if let equipment {
            equipment.name = trimmedName
            equipment.icon = icon
            Log.persistence.info("Equipment updated: \(trimmedName)")
        } else {
            let newEquipment = Equipment(name: trimmedName, icon: icon)
            modelContext.insert(newEquipment)
            do {
                try modelContext.save()
                Log.persistence.info("Equipment created: \(trimmedName)")
            } catch {
                Log.persistence.error("Failed to save equipment: \(error.localizedDescription)")
                errorHandler.show("Could not save the equipment. Please try again.")
            }
        }
    }

    private func isDisabled() -> Bool {
        return name.trimmingCharacters(in: .whitespaces).isEmpty || isDuplicate
    }

    private func checkDuplicate(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            isDuplicate = false
            return
        }
        do {
            isDuplicate = try Equipment.isDuplicateName(trimmed, excludingID: equipment?.id, in: modelContext)
        } catch {
            // Fail open: transient SwiftData errors shouldn't lock the user out of creating equipment.
            Log.persistence.error("Failed to check duplicate equipment name: \(error.localizedDescription)")
            isDuplicate = false
        }
    }
}

#Preview {
    EquipmentEditor(equipment: nil)
}
