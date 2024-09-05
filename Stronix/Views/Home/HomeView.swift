//
//  HomeView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Query private let workouts: [Workout]
    
    var body: some View {
        NavigationStack {
            List {
                
                NavigationLink("Start Workout") {
                    CurrentWorkoutView()
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.blue)
            }
            
            Button("Test") {
                print(workouts)
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
