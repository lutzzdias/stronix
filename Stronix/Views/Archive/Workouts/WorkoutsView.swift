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
                }.onDelete(perform: delete)
            }
            .searchable(text: $query)
            .navigationTitle("Workouts")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }
    
    private func delete(at indexes: IndexSet) {
        for index in indexes {
            let workout = workouts[index]
            modelContext.delete(workout)
        }
    }
}

#Preview {
    let preview = Preview()
    
    return WorkoutsView()
        .modelContainer(preview.container)
}
