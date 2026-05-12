//
//  MuscleGroupEditor.swift
//  Stronix
//

import SwiftUI
import SwiftData

struct MuscleGroupEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(ErrorHandler.self) var errorHandler

    let muscleGroup: MuscleGroup?

    private var editorTitle: String {
        muscleGroup == nil ? "Add Muscle Group" : "Edit Muscle Group"
    }

    @State private var name: String = ""
    @State private var desc: String?
    @State private var isDuplicate: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }

                Section("Description") {
                    TextField("Description", text: Binding(
                        get: { desc ?? "" },
                        set: { value in
                            desc = value
                        }
                    ), axis: .vertical)
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
                if let muscleGroup {
                    name = muscleGroup.name
                    desc = muscleGroup.desc
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
        let trimmedDesc = desc?.trimmingCharacters(in: .whitespaces)

        if let muscleGroup {
            muscleGroup.name = trimmedName
            muscleGroup.desc = trimmedDesc
            Log.persistence.info("Muscle group updated: \(trimmedName)")
        } else {
            let newMuscleGroup = MuscleGroup(name: trimmedName, desc: trimmedDesc)
            modelContext.insert(newMuscleGroup)
            do {
                try modelContext.save()
                Log.persistence.info("Muscle group created: \(trimmedName)")
            } catch {
                Log.persistence.error("Failed to save muscle group: \(error.localizedDescription)")
                errorHandler.show("Could not save the muscle group. Please try again.")
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
            isDuplicate = try MuscleGroup.isDuplicateName(trimmed, excludingID: muscleGroup?.id, in: modelContext)
        } catch {
            // Fail open: transient SwiftData errors shouldn't lock the user out of creating muscle groups.
            Log.persistence.error("Failed to check duplicate muscle group name: \(error.localizedDescription)")
            isDuplicate = false
        }
    }
}

#Preview {
    MuscleGroupEditor(muscleGroup: nil)
}
