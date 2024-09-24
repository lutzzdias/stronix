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

    // TODO: Remove already added exercises from this list
    @Query private var allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    @State private var selectedExercises: Set<Exercise> = Set()
    
    let onAdd: (Set<Exercise>) -> Void
    
    var exercises: [Exercise] {
        guard !query.isEmpty else { return allExercises }
        return allExercises.filter { exercise in
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
                    }
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
    
    return AddExerciseSheetView(onAdd: {_ in })
        .modelContainer(preview.container)
}
