//
//  CurrentWorkoutView.swift
//  Stronix
//
//  Created by Thiago Dias on 28/08/24.
//

import SwiftUI
import SwiftData

struct CurrentWorkoutView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    
    @State private var workout: Workout? = nil
    @State private var isShowingExercisesSheet = false
    
    private var workoutName: Binding<String> {
        Binding<String> {
            workout?.name ?? ""
        } set: { name in
            workout?.name = name
        }
    }
    
    private var workoutDesc: Binding<String> {
        Binding<String> {
            workout?.comment ?? ""
        } set: { desc in
            workout?.comment = desc
        }
    }
    
    var body: some View {
        TimerView(startDate: workout?.start ?? Date.now)
        
        List {
            // MARK: Title and description
            Section {
                TextField("Name", text: workoutName)
                TextField("Description", text: workoutDesc)
            }
            
            // MARK: Exercises
            Section("Exercises") {
                ForEach(workout?.exercises ?? []) { workoutExercise in
                    VStack{
                        Text(workoutExercise.exercise.name)
                    }
                }
                
                Button("Add exercise", systemImage: "plus") {
                    isShowingExercisesSheet = true
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    workout?.end = Date.now
                    context.insert(workout!)
                    workout = nil
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    workout = nil
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $isShowingExercisesSheet) {
            AddExerciseSheetView()
        }
        .onAppear {
            workout = Workout()
        }
    }
}

#Preview {
    let preview = Preview()
    
    return NavigationStack {
        CurrentWorkoutView()
            .modelContainer(preview.container)
    }
}
