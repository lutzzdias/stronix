//
//  ExerciseDetailView.swift
//  Stronix
//
//  Created by Thiago Dias on 20/08/24.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        List {
            Text(workout.comment)
        }
        .navigationTitle(workout.name)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    showEditSheet.toggle()
                }
                .sheet(isPresented: $showEditSheet) {
                    Text("Edit")
                }
            }
        }
    }
}

#Preview {
    WorkoutDetailView(workout: Workout.sample[0])
}
