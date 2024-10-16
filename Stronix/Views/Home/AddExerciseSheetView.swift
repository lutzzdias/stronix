//
//  ExercisesView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct AddExerciseSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query private var allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    @State private var selectedExercises: Set<Exercise> = Set()
    
    let addedExercises: Set<Exercise>
    let onAdd: (Set<Exercise>) -> Void
    
    var exercises: [Exercise] {
        let filteredExercises: [Exercise] = allExercises.filter { !addedExercises.contains($0) }
        guard !query.isEmpty else { return filteredExercises }
        return filteredExercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        // TODO: button for create exercise if search returns no items
        NavigationStack {
            List(exercises, id: \.self, selection: $selectedExercises) { exercise in
                Text(exercise.name).tag(exercise.id)
            }
            .searchable(text: $query)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(selectedExercises)
                    }.disabled(selectedExercises.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let preview = Preview()
    
    return AddExerciseSheetView(addedExercises: Set(), onAdd: {_ in })
        .modelContainer(preview.container)
}
