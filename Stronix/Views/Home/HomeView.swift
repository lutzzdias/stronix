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
            .navigationTitle("Home")
        }
    }
}

#Preview {
    let preview = Preview()
    
    return HomeView()
        .modelContainer(preview.container)
}
