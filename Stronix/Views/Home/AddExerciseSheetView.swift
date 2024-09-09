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

    @Query private let allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    @State private var selectedExercises: Set<Exercise> = Set()
    
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
                    Text(exercise.name)
                }
            }
            .searchable(text: $query)
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    let preview = Preview()
    
    return AddExerciseSheetView()
        .modelContainer(preview.container)
}
