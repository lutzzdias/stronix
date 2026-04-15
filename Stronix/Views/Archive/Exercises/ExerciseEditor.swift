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
            }
        }
    }
    
    private func save() {
        if let exercise {
            exercise.name = name
            exercise.desc = desc
            exercise.equipment = equipment
            exercise.muscle = muscle
            Log.persistence.info("Exercise updated: \(name)")
        } else {
            let exercise = Exercise(
                name: name,
                desc: desc,
                equipment: equipment,
                muscle: muscle
            )
            modelContext.insert(exercise)
            do {
                try modelContext.save()
                Log.persistence.info("Exercise created: \(name)")
            } catch {
                Log.persistence.error("Failed to save exercise: \(error.localizedDescription)")
                errorHandler.show("Could not save the exercise. Please try again.")
            }
        }
    }
    
    private func isDisabled() -> Bool {
        // TODO: check if there already exists an exercise with the same name
        return name.isEmpty
    }
}

#Preview {
    ExerciseEditor(exercise: nil)
}
