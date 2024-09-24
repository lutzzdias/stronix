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
    @Query var exercises: [Exercise]
    
    @State private var showCreateSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("History") {
                    ForEach(workouts.prefix(5)) { workout in
                        NavigationLink(value: workout) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(workout.name)
                                    Text(workout.date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(workout.durationStr)
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkout)
                    
                    if (workouts.count > 5) {
                        NavigationLink("See all") {
                            WorkoutsView()
                        }
                        .foregroundStyle(.blue)
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
                    }
                    .onDelete(perform: deleteExercise)
                    
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
        }
    }
    
    func deleteWorkout(at indexes: IndexSet) {
        for index in indexes {
            let workout = workouts[index]
            context.delete(workout)
        }
    }
    
    func deleteExercise(at indexes: IndexSet) {
        for index in indexes {
            let exercise = exercises[index]
            context.delete(exercise)
        }
    }
}

#Preview {
    let preview = Preview()
    
    return ArchiveView()
        .modelContainer(preview.container)
}
