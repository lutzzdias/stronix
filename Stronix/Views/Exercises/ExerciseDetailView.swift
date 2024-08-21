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
            
            if let muscle = exercise.muscle {
                HStack {
                    Text("Muscle")
                    Spacer()
                    Text(muscle)
                        .foregroundStyle(.secondary)
                }
            }
            
            if let equipment = exercise.equipment {
                HStack {
                    Text("Equipment")
                    Spacer()
                    Text(equipment)
                        .foregroundStyle(.secondary)
                }
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
