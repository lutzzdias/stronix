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
    
    @Query(filter: Exercise.activePredicate, sort: \Exercise.name) private var allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    @State private var selectedExercises: Set<Exercise> = Set()
    
    let addedExercises: Set<Exercise>
    let onAdd: (Set<Exercise>) -> Void
    
    /// Selectable exercises, most-used first so frequent picks sit at the top.
    ///
    /// `usageCount` is derived from a relationship and so cannot be a `@Query` sort;
    /// the sort happens here instead. Ties fall back to name — `sorted(by:)` is not
    /// guaranteed stable, so equally-used exercises need an explicit tie-break to
    /// keep their order from shifting between redraws.
    var exercises: [Exercise] {
        let filteredExercises: [Exercise] = allExercises.filter { !addedExercises.contains($0) }
        let matching = query.isEmpty
            ? filteredExercises
            : filteredExercises.filter { $0.name.localizedCaseInsensitiveContains(query) }
        return matching.sorted { left, right in
            left.usageCount == right.usageCount
                ? left.name.localizedCompare(right.name) == .orderedAscending
                : left.usageCount > right.usageCount
        }
    }
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedExercises){
                ForEach(exercises, id: \.self) { exercise in
                    Text(exercise.name).tag(exercise.id)
                }
                
                Button {
                    showCreateSheet.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create new")
                    }
                }
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
            .sheet(isPresented: $showCreateSheet) {
                ExerciseEditor(exercise: nil)
            }
        }
    }
}

#Preview {
    let preview = Preview()
    
    return AddExerciseSheetView(addedExercises: Set(), onAdd: {_ in })
        .modelContainer(preview.container)
}
