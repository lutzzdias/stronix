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
    
    let exercise: Exercise?
    
    private var editorTitle: String {
        exercise == nil ? "Add Exercise" : "Edit Exercise"
    }
    
    @State private var name: String = ""
    @State private var description: String?
    @State private var equipment: String?
    @State private var muscle: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Description", text: Binding(
                        get: { description ?? ""},
                        set: {  desc in
                            description = desc
                        }
                    ), axis: .vertical)
                }
                
                // TODO: change to picker
                Section("Equipment") {
                    TextField("Equipment", text: Binding(
                        get: { equipment ?? ""},
                        set: {  eq in
                            equipment = eq
                        }
                    ))
                }
                
                // TODO: change to picker and allow more than 1 muscle
                Section("Muscles") {
                    TextField("Muscle", text: Binding(
                        get: { muscle ?? ""},
                        set: {  musc in
                            muscle = musc
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
                            dismiss()
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
                    description = exercise.desc
                    equipment = exercise.equipment
                    muscle = exercise.muscle
                }
            }
        }
    }
    
    private func save() {
        if let exercise {
            exercise.name = name
            exercise.desc = description
            exercise.equipment = equipment
            exercise.muscle = muscle
        } else {
            let ex = Exercise(
                name: name,
                desc: description,
                equipment: equipment,
                muscle: muscle
            )
            modelContext.insert(ex)
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
