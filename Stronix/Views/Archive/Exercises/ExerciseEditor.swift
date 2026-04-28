//
//  CreateExerciseSheet.swift
//  Stronix
//
//  Created by Thiago Dias on 21/08/24.
//

import SwiftUI

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(ErrorHandler.self) var errorHandler
    
    let exercise: Exercise?
    
    private var editorTitle: String {
        exercise == nil ? "Add Exercise" : "Edit Exercise"
    }
    
    @State private var name: String = ""
    @State private var desc: String?
    @State private var equipment: String?
    @State private var muscle: String?
    @State private var isDuplicate: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: Binding(
                        get: { desc ?? ""},
                        set: { value in
                            desc = value
                        }
                    ), axis: .vertical)
                }
                
                // TODO: change to picker
                Section("Equipment") {
                    TextField("Equipment", text: Binding(
                        get: { equipment ?? ""},
                        set: {  value in
                            equipment = value
                        }
                    ))
                }
                
                // TODO: change to picker and allow more than 1 muscle
                Section("Muscles") {
                    TextField("Muscle", text: Binding(
                        get: { muscle ?? ""},
                        set: {  value in
                            muscle = value
                        }
                    ))
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
                if let exercise {
                    name = exercise.name
                    desc = exercise.desc
                    equipment = exercise.equipment
                    muscle = exercise.muscle
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
        let trimmedEquipment = equipment?.trimmingCharacters(in: .whitespaces)
        let trimmedMuscle = muscle?.trimmingCharacters(in: .whitespaces)

        if let exercise {
            exercise.name = trimmedName
            exercise.desc = trimmedDesc
            exercise.equipment = trimmedEquipment
            exercise.muscle = trimmedMuscle
            Log.persistence.info("Exercise updated: \(trimmedName)")
        } else {
            let exercise = Exercise(
                name: trimmedName,
                desc: trimmedDesc,
                equipment: trimmedEquipment,
                muscle: trimmedMuscle
            )
            modelContext.insert(exercise)
            do {
                try modelContext.save()
                Log.persistence.info("Exercise created: \(trimmedName)")
            } catch {
                Log.persistence.error("Failed to save exercise: \(error.localizedDescription)")
                errorHandler.show("Could not save the exercise. Please try again.")
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
            isDuplicate = try Exercise.isDuplicateName(trimmed, excludingID: exercise?.id, in: modelContext)
        } catch {
            // Fail open: transient SwiftData errors shouldn't lock the user out of creating exercises.
            Log.persistence.error("Failed to check duplicate exercise name: \(error.localizedDescription)")
            isDuplicate = false
        }
    }
}

#Preview {
    ExerciseEditor(exercise: nil)
}
