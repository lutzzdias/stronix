//
//  ExerciseDetailView.swift
//  Stronix
//
//  Created by Thiago Dias on 20/08/24.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    
    // TODO: Allow edit
    var body: some View {
        List {
            Section {
                // TODO: convert to TextField ??
                Text(workout.name)
                Text(workout.comment)
            }
            
            HStack {
                Spacer()
                
                // TODO: extract into subview
                VStack {
                    Text(workout.durationStr)
                        .font(.title3)
                    
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // TODO: extract into subview
                VStack {
                    Text(String(describing: workout.numberOfSets))
                        .font(.title3)
                    
                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text(String(describing: workout.totalWeight))
                        .font(.title3)
                    
                    Text("Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Section {
                // TODO: allow editing
                DatePicker("Start", selection: .constant(workout.start))
                    .disabled(true)
                // TODO: assert end is always set in this screen
                DatePicker("End", selection: .constant(workout.end ?? Date.now))
                    .disabled(true)
            }
            
            ForEach(workout.exercises) { workoutExercise in
                VStack(alignment: .leading) {
                    Text(workoutExercise.exercise.name)
                    
                    ForEach(workoutExercise.sets) { wset in
                        Text("\(String(format: "%g", wset.weight)) x \(wset.repetitions)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout.sample.first!)
    }
}
