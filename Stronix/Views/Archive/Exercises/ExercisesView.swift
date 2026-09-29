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
    @Environment(ErrorHandler.self) private var errorHandler

    @Query(filter: Exercise.activePredicate, sort: \Exercise.name) private var allExercises: [Exercise]
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
                    do {
                        try modelContext.save()
                        Log.persistence.info("Exercise archived: \(exercise.name)")
                    } catch {
                        Log.persistence.error("Failed to archive exercise: \(error.localizedDescription)")
                        errorHandler.show("Could not archive \(exercise.name). Please try again.")
                    }
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
        .environment(ErrorHandler())
}
