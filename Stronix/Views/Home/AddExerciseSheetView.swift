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
    
    @Query(filter: Exercise.activePredicate) private var allExercises: [Exercise]
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
