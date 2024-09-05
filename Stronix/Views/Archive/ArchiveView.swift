//
//  HomeView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Query(sort: \Workout.end, order: .reverse) var workouts: [Workout]
    @Query var exercises: [Exercise]
    
    var body: some View {
        NavigationStack {
            List {
                Section("History") {
                    ForEach(workouts) { workout in
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
                    
                    // TODO: Add "more" beside section title and remove this button
                    NavigationLink("See all") {
                        WorkoutsView()
                    }
                    .foregroundStyle(.blue)
                }
                
                Section("Exercises") {
                    ForEach(exercises) { exercise in
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
                    
                    // TODO: Add "more" beside section title and remove this button
                    NavigationLink("See all") {
                        ExercisesView()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Archive")
            .navigationDestination(for: Exercise.self) { ExerciseDetailView(exercise: $0) }
            .navigationDestination(for: Workout.self) { WorkoutDetailView(workout: $0) }
        }
    }
}

#Preview {
    let preview = Preview(Workout.self, WorkoutExercise.self, Exercise.self)
    
    preview.addData(Exercise.sample)
    preview.addData(WorkoutExercise.sample)
    preview.addData(Workout.sample)
    
    return ArchiveView()
        .modelContainer(preview.container)
}
