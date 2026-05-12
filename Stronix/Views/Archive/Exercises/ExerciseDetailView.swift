//
//  ExerciseDetailView.swift
//  Stronix
//
//  Created by Thiago Dias on 20/08/24.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        List {
            if let desc = exercise.desc { Text(desc) }
            
            if !exercise.primaryMuscles.isEmpty {
                HStack {
                    Text("Primary")
                    Spacer()
                    Text(exercise.primaryMuscles.map(\.name).joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
            }

            if !exercise.secondaryMuscles.isEmpty {
                HStack {
                    Text("Secondary")
                    Spacer()
                    Text(exercise.secondaryMuscles.map(\.name).joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
            }
            
            if let equipment = exercise.equipment {
                Label(equipment.name, systemImage: equipment.icon)
            }
            
            // TODO: Show most recent weight and reps (workoutExercise relation) with an option to see entire history
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem {
                Button("Edit") {
                    showEditSheet.toggle()
                }
                .sheet(isPresented: $showEditSheet) {
                    ExerciseEditor(exercise: exercise)
                }
            }
        }
    }
}

#Preview {
    ExerciseDetailView(exercise: Exercise.sample[0])
}
