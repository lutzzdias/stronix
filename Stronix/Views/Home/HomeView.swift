//
//  HomeView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var workouts: [Workout]
    
    @State private var activeWorkout: Workout?
    
    var body: some View {
        NavigationStack {
            List {
                
                Button("Start Workout") {
                    activeWorkout = Workout()
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.blue)
            }
            .navigationTitle("Home")
            .navigationDestination(item: $activeWorkout) { workout in
                CurrentWorkoutView(workout: workout)
            }
        }
    }
}

#Preview {
    let preview = Preview()
    
    return HomeView()
        .modelContainer(preview.container)
}
