//
//  WorkoutSummarySheet.swift
//  Stronix
//

import SwiftUI

struct WorkoutSummarySheet: View {
    let onSave: () -> Void
    let onCancel: () -> Void
    
    let duration: String
    let setsCount: String
    let volume: String
    let shareText: String
    let exercises: [(name: String, sets: [(weight: String, reps: Int)])]
    
    init(workout: Workout, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.onSave = onSave
        self.onCancel = onCancel
        self.duration = AppFormatter.duration(workout.duration)
        self.shareText = workout.shareText
        
        let completed = workout.sortedExercises.compactMap { exercise -> (name: String, sets: [(weight: String, reps: Int)])? in
            let sets = exercise.sortedSets.filter(\.completed).map {
                (weight: String(format: "%g", $0.weight ?? 0), reps: $0.repetitions ?? 0)
            }
            guard !sets.isEmpty else { return nil }
            return (name: exercise.exercise?.name ?? "", sets: sets)
        }
        self.exercises = completed
        self.setsCount = "\(completed.reduce(0) { $0 + $1.sets.count })"
        // Volume from completed sets only
        let totalVolume = workout.sortedExercises.reduce(0.0) { total, exercise in
            total + exercise.sortedSets.filter(\.completed).reduce(0.0) { vol, set in
                vol + (set.weight ?? 0) * Double(set.repetitions ?? 0)
            }
        }
        self.volume = "\(String(format: "%g", totalVolume)) kg"
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        stat(duration, label: "Duration")
                        Spacer()
                        stat(setsCount, label: "Sets")
                        Spacer()
                        stat(volume, label: "Volume")
                        Spacer()
                    }
                }
                
                ForEach(exercises.indices, id: \.self) { i in
                    Section(exercises[i].name) {
                        ForEach(exercises[i].sets.indices, id: \.self) { j in
                            Text("\(exercises[i].sets[j].weight) kg × \(exercises[i].sets[j].reps)")
                        }
                    }
                }
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: onSave) {
                        Image(systemName: "checkmark")
                    }
                }
            }
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
