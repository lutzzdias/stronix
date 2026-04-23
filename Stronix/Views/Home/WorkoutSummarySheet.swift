//
//  WorkoutSummarySheet.swift
//  Stronix
//

import SwiftUI

struct WorkoutSummarySheet: View {
    let workout: Workout
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: Stats banner
                Section {
                    HStack {
                        Spacer()
                        stat(AppFormatter.duration(workout.duration), label: "Duration")
                        Spacer()
                        stat("\(workout.numberOfSets)", label: "Sets")
                        Spacer()
                        stat("\(String(format: "%g", workout.totalWeight)) kg", label: "Volume")
                        Spacer()
                    }
                }
                
                // MARK: Exercise list with completed sets
                ForEach(workout.sortedExercises) { exercise in
                    Section(exercise.exercise?.name ?? "") {
                        ForEach(exercise.sortedSets) { set in
                            Text("\(String(format: "%g", set.weight ?? 0)) kg × \(set.repetitions ?? 0)")
                        }
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                }
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: workout.shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            // Prevent accidental swipe-dismiss after finish() has mutated the workout
            .interactiveDismissDisabled()
        }
    }
    
    private func stat(_ value: String, label: String) -> some View {
        VStack {
            Text(value).font(.title3)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
