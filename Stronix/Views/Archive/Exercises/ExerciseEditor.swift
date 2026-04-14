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
        } else {
            let exercise = Exercise(
                name: name,
                desc: desc,
                equipment: equipment,
                muscle: muscle
            )
            modelContext.insert(exercise)
            try? modelContext.save()
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
