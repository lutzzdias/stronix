//
//  CreateExerciseSheet.swift
//  Stronix
//
//  Created by Thiago Dias on 21/08/24.
//

import SwiftUI
import SwiftData

struct ExerciseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(ErrorHandler.self) var errorHandler
    
    @Query(sort: \Equipment.name) private var allEquipment: [Equipment]
    @Query(sort: \MuscleGroup.name) private var allMuscleGroups: [MuscleGroup]

    let exercise: Exercise?

    private var editorTitle: String {
        exercise == nil ? "Add Exercise" : "Edit Exercise"
    }

    @State private var name: String = ""
    @State private var desc: String?
    @State private var equipment: Equipment?
    @State private var primaryMuscles: Set<MuscleGroup> = []
    @State private var secondaryMuscles: Set<MuscleGroup> = []
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
                
                Section("Equipment") {
                    Picker("Equipment", selection: $equipment) {
                        Text("None").tag(Equipment?.none)
                        ForEach(allEquipment) { eq in
                            Label(eq.name, systemImage: eq.icon).tag(Equipment?.some(eq))
                        }
                    }
                }
                
                Section("Primary Muscles") {
                    ForEach(allMuscleGroups, id: \.self) { group in
                        Button {
                            if primaryMuscles.contains(group) {
                                primaryMuscles.remove(group)
                            } else {
                                primaryMuscles.insert(group)
                            }
                        } label: {
                            HStack {
                                Image(systemName: primaryMuscles.contains(group) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(primaryMuscles.contains(group) ? .blue : .gray.opacity(0.4))
                                    .imageScale(.large)
                                Text(group.name)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Secondary Muscles") {
                    ForEach(allMuscleGroups, id: \.self) { group in
                        Button {
                            if secondaryMuscles.contains(group) {
                                secondaryMuscles.remove(group)
                            } else {
                                secondaryMuscles.insert(group)
                            }
                        } label: {
                            HStack {
                                Image(systemName: secondaryMuscles.contains(group) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(secondaryMuscles.contains(group) ? .blue : .gray.opacity(0.4))
                                    .imageScale(.large)
                                Text(group.name)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
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
                    primaryMuscles = Set(exercise.primaryMuscles)
                    secondaryMuscles = Set(exercise.secondaryMuscles)
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
        if let exercise {
            exercise.name = trimmedName
            exercise.desc = trimmedDesc
            exercise.equipment = equipment
            exercise.primaryMuscles = Array(primaryMuscles)
            exercise.secondaryMuscles = Array(secondaryMuscles)
            Log.persistence.info("Exercise updated: \(trimmedName)")
        } else {
            let exercise = Exercise(
                name: trimmedName,
                desc: trimmedDesc,
                equipment: equipment,
                primaryMuscles: Array(primaryMuscles),
                secondaryMuscles: Array(secondaryMuscles)
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
