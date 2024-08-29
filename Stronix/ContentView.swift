//
//  ContentView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/08/24.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case home, exercises, settings
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            
            ExercisesView()
                .tabItem {
                    Label("Exercises", systemImage: "tray.full")
                }
                .tag(Tab.exercises)
            
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    let preview = Preview(Workout.self, WorkoutExercise.self, Exercise.self)
    
    preview.addData(Exercise.sample)
    preview.addData(WorkoutExercise.sample)
    preview.addData(Workout.sample)
    
    return ContentView()
        .modelContainer(preview.container)
}
