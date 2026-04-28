//
//  HomeView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) var context
    
    @Query(sort: \Workout.end) var workouts: [Workout]
    @Query(filter: Exercise.activePredicate) var exercises: [Exercise]
    
    @State private var showCreateSheet: Bool = false
    @State private var pendingWorkoutDeletion: Workout?
    @State private var isShowingWorkoutDeleteConfirm = false
    @State private var pendingExerciseArchive: Exercise?
    @State private var isShowingExerciseArchiveConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section("History") {
                    ForEach(workouts.prefix(5)) { workout in
                        NavigationLink(value: workout) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(workout.name)
                                    Text(AppFormatter.date(workout.start))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(AppFormatter.duration(workout.duration))
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", role: .destructive) {
                                pendingWorkoutDeletion = workout
                                isShowingWorkoutDeleteConfirm = true
                            }
                        }
                    }

                    if (workouts.count > 5) {
                        NavigationLink("See all") {
                            WorkoutsView()
                        }
                        .foregroundStyle(.blue)
                    } else if (workouts.isEmpty) {
                        Text("No workouts yet")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Exercises") {
                    // TODO: customize section and make this button be simple + beside section title
                    Button {
                        showCreateSheet.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create exercise")
                        }
                    }
                    .foregroundStyle(.blue)
                    
                    ForEach(exercises.prefix(5)) { exercise in
                        NavigationLink(value: exercise) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                    Text(exercise.muscle ?? "all")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Archive", role: .destructive) {
                                pendingExerciseArchive = exercise
                                isShowingExerciseArchiveConfirm = true
                            }
                        }
                    }

                    if (exercises.count > 5) {
                        NavigationLink("See all") {
                            ExercisesView()
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Archive")
            .navigationDestination(for: Exercise.self) { ExerciseDetailView(exercise: $0) }
            .navigationDestination(for: Workout.self) { WorkoutDetailView(workout: $0) }
            .sheet(isPresented: $showCreateSheet) {
                ExerciseEditor(exercise: nil)
            }
            .alert("Delete workout?", isPresented: $isShowingWorkoutDeleteConfirm, presenting: pendingWorkoutDeletion) { workout in
                Button("Delete", role: .destructive) {
                    context.delete(workout)
                    Log.persistence.info("Workout deleted: \(workout.name)")
                }
                Button("Cancel", role: .cancel) { }
            } message: { _ in
                Text("This action cannot be undone.")
            }
            .alert("Archive exercise?", isPresented: $isShowingExerciseArchiveConfirm, presenting: pendingExerciseArchive) { exercise in
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
    
    return ArchiveView()
        .modelContainer(preview.container)
}
