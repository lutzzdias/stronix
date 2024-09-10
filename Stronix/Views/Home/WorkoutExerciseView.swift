//
//  WorkoutExerciseView.swift
//  Stronix
//
//  Created by Thiago Dias on 10/09/24.
//

import SwiftUI

struct WorkoutExerciseView: View {
    @Environment(\.modelContext) var context
    
    @Bindable var workoutExercise: WorkoutExercise
    @State var selectedSet: WorkoutSet? = nil
    
    var body: some View {
        Text(workoutExercise.workout?.name ?? "")
        TimerView(startDate: workoutExercise.workout?.start ?? Date.now)
        
        List {
            Section {
                TextField("Comment", text: $workoutExercise.comment)
                
                ForEach(Array(workoutExercise.sets.enumerated()), id: \.element.id) { index, workoutSet in
                    HStack {
                        Text("\(String(format: "%g", workoutSet.weight)) × \(workoutSet.repetitions)")
                        Spacer()
                        Text("\(index + 1)")
                            .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        if (selectedSet == workoutSet) { selectedSet = nil }
                        else { selectedSet = workoutSet }
                    }
                }
                .onDelete(perform: delete)
                
                Button {
                    Task { @MainActor in
                        let workoutSet = WorkoutSet()
                        context.insert(workoutSet)
                        workoutExercise.sets.append(workoutSet)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add set")
                    }
                }
            }
            
            // TODO: Fetch previous workoutSets for this exercise
        }
        
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                HStack {
                    HStack {
                        Text(String(describing: selectedSet?.repetitions))
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // TODO: Implement dragger
                    Image(systemName: "line.horizontal.3")
                }
                
                Divider().frame(height: 44)
                
                HStack {
                    HStack {
                        Text(String(describing: selectedSet?.repetitions))
                        Text("reps")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // TODO: Implement dragger
                    Image(systemName: "line.horizontal.3")
                }
            }
            
        }.padding([.leading, .trailing])
    }
    
    func delete(at indexes: IndexSet) {
        for index in indexes {
            let workoutSet = workoutExercise.sets.remove(at: index)
            if (workoutSet == selectedSet) { selectedSet = nil }
            context.delete(workoutSet)
        }
    }
}

#Preview {
    let preview = Preview()
    let workoutExercise = WorkoutExercise(exercise: Exercise(name: "Test"))
    preview.container.mainContext.insert(workoutExercise)
    
    return WorkoutExerciseView(workoutExercise: workoutExercise)
        .modelContainer(preview.container)
}
