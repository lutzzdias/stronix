//
//  ExercisesView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    
    var exercises: [Exercise] {
        guard !query.isEmpty else { return allExercises }
        return allExercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises) { exercise in
                    NavigationLink(value: exercise) {
                        Text(exercise.name)
                    }
                }.onDelete(perform: delete)
            }
            .searchable(text: $query)
            .navigationTitle("Exercises")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showCreateSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showCreateSheet) {
                        ExerciseEditor(exercise: nil)
                    }
                }
            }
        }
    }
    
    private func delete(at indexes: IndexSet) {
        for index in indexes {
            let exercise = exercises[index]
            modelContext.delete(exercise)
        }
    }
}

#Preview {
    let preview = Preview()
    
    return ExercisesView()
        .modelContainer(preview.container)
}
