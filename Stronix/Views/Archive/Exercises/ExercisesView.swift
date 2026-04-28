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

    @Query(filter: Exercise.activePredicate) private var allExercises: [Exercise]
    @State private var query: String = ""
    @State private var showCreateSheet: Bool = false
    @State private var pendingArchive: Exercise?
    @State private var isShowingArchiveConfirm = false

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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Archive", role: .destructive) {
                            pendingArchive = exercise
                            isShowingArchiveConfirm = true
                        }
                    }
                }
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
            .alert("Archive exercise?", isPresented: $isShowingArchiveConfirm, presenting: pendingArchive) { exercise in
                Button("Archive", role: .destructive) {
                    exercise.isArchived = true
                    Log.persistence.info("Exercise archived: \(exercise.name)")
                }
                Button("Cancel", role: .cancel) { }
            } message: { _ in
                Text("You can still view it in past workouts.")
            }
        }
    }
}

#Preview {
    let preview = Preview()
    
    return ExercisesView()
        .modelContainer(preview.container)
}
