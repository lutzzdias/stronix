//
//  ExercisesView.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

// TODO: make generic view that can be used for both workouts and exercises

import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var allWorkouts: [Workout]
    @State private var query: String = ""
    @State private var pendingDeletion: Workout?
    @State private var isShowingDeleteConfirm = false

    var workouts: [Workout] {
        guard !query.isEmpty else { return allWorkouts }
        return allWorkouts.filter { workout in
            workout.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) {
                        Text(workout.name)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            pendingDeletion = workout
                            isShowingDeleteConfirm = true
                        }
                    }
                }
            }
            .searchable(text: $query)
            .navigationTitle("Workouts")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .alert("Delete workout?", isPresented: $isShowingDeleteConfirm, presenting: pendingDeletion) { workout in
                Button("Delete", role: .destructive) {
                    modelContext.delete(workout)
                    Log.persistence.info("Workout deleted: \(workout.name)")
                }
                Button("Cancel", role: .cancel) { }
            } message: { _ in
                Text("This action cannot be undone.")
            }
        }
    }
}

#Preview {
    let preview = Preview()
    
    return WorkoutsView()
        .modelContainer(preview.container)
}
