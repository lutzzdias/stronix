//
//  ContentView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/08/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query
    var exercises: [Exercise]
    
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }
            
            ExercisesView().tabItem {
                Label("Exercises", systemImage: "tray.full")
            }
            
            
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(previewContainer)
}
