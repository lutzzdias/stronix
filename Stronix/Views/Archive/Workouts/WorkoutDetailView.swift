//
//  WorkoutDetailView.swift
//  Stronix
//
//  Created by Thiago Dias on 20/08/24.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    @AppStorage(WeightUnit.storageKey) private var weightUnit: WeightUnit = .kilograms
    @State private var isEditing = false

    var body: some View {
        List {
            Section {
                Text(workout.name)
                if !workout.comment.isEmpty {
                    Text(workout.comment)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Spacer()

                VStack {
                    Text(AppFormatter.duration(workout.duration))
                        .font(.title3)

                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack {
                    Text(String(describing: workout.numberOfSets))
                        .font(.title3)

                    Text("Sets")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack {
                    Text(AppFormatter.weight(workout.totalWeight, in: weightUnit))
                        .font(.title3)

                    Text("Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Section {
                DatePicker("Start", selection: .constant(workout.start))
                    .disabled(true)
                DatePicker("End", selection: .constant(workout.end ?? Date.now))
                    .disabled(true)
            }

            ForEach(workout.sortedExercises) { workoutExercise in
                Section(workoutExercise.exercise?.name ?? "Unknown") {
                    ForEach(workoutExercise.sortedSets) { workoutSet in
                        HStack {
                            Text("\(AppFormatter.weight(workoutSet.weight ?? 0, in: weightUnit)) × \(workoutSet.repetitions ?? 0)")
                                .foregroundStyle(.secondary)

                            Spacer()

                            if let rpe = workoutSet.rpe {
                                Text(rpe.label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let tag = workoutSet.tag {
                                Text(tag.shortLabel)
                                    .font(.caption2).bold()
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(.secondary, in: .capsule)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .navigationDestination(isPresented: $isEditing) {
            WorkoutEditorView(mode: .editing, workout: workout)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout.sample[0])
    }
}
