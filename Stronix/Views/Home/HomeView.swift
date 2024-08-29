//
//  HomeView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Workout.end, order: .reverse) var workouts: [Workout]
    
    var body: some View {
        NavigationStack {
            List {
                // TODO: Add "more" beside section title
                Section("History") {
                    ForEach(workouts) { workout in
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
                
                NavigationLink("Start Workout") {
                    CurrentWorkoutView()
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.blue)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    let preview = Preview(Workout.self, WorkoutExercise.self, Exercise.self)
    
    preview.addData(Exercise.sample)
    preview.addData(WorkoutExercise.sample)
    preview.addData(Workout.sample)
    
    return HomeView()
        .modelContainer(preview.container)
}
