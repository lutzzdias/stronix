//
//  WorkoutEditorView.swift
//  Stronix
//
//  Unified workout editor for both active (new) and editing (historical) workouts.
//

import SwiftUI
import SwiftData

struct WorkoutEditorView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @Environment(ErrorHandler.self) var errorHandler
    @Environment(RestTimer.self) var restTimer
    @AppStorage(WeightUnit.storageKey) private var weightUnit: WeightUnit = .kilograms

    let mode: WorkoutMode
    @Bindable var workout: Workout

    @State private var isShowingExercisesSheet = false
    @State private var isShowingSummary = false
    @State private var isShowingCancelConfirm = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        List {
            // MARK: Title and description
            Section {
                TextField("Name", text: $workout.name)
                    .focused($isTextFieldFocused)
                TextField("Description", text: $workout.comment, axis: .vertical)
                    .focused($isTextFieldFocused)
            }

            // MARK: Stats & dates (edit mode only)
            if mode == .editing {
                HStack {
                    Spacer()
                    statView(AppFormatter.duration(workout.duration), label: "Duration")
                    Spacer()
                    statView(String(describing: workout.numberOfSets), label: "Sets")
                    Spacer()
                    statView(AppFormatter.weight(workout.totalVolume, in: weightUnit), label: "Volume")
                    Spacer()
                }

                Section {
                    DatePicker("Start", selection: $workout.start)
                    DatePicker("End", selection: endDateBinding)
                }
            }

            // MARK: Exercises
            Section("Exercises") {
                ForEach(workout.sortedExercises) { workoutExercise in
                    NavigationLink(destination: WorkoutExerciseView(workout: workout, workoutExercise: workoutExercise, mode: mode)) {
                        Text(workoutExercise.exercise?.name ?? "Unknown")
                    }
                }
                .onMove { source, destination in workout.moveExercises(from: source, to: destination) }
                .onDelete { indexes in deleteExercises(at: indexes) }

                Button("Add exercise", systemImage: "plus") {
                    isShowingExercisesSheet = true
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if mode == .active {
                TimerView(startDate: workout.start)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            if mode == .active {
                Log.workout.info("Workout started")
            } else {
                context.autosaveEnabled = false
            }
        }
        .onDisappear {
            // Safety net: re-enable autosave if view disappears without Done/Cancel
            if mode == .editing {
                context.autosaveEnabled = true
            }
        }
        .toolbar {
            // MARK: Active mode toolbar
            if mode == .active {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if workout.hasCompletedSets {
                            isShowingCancelConfirm = true
                        } else {
                            discardActiveWorkout()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") {
                        Log.workout.info("Summary generated")
                        isShowingSummary = true
                    }
                }
            }

            // MARK: Edit mode toolbar
            if mode == .editing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        rollbackAndDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                }
            }

            // MARK: Keyboard dismiss (both modes)
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isTextFieldFocused = false
                } label: {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                }
            }
        }
        .alert("Cancel workout?", isPresented: $isShowingCancelConfirm) {
            Button("Discard", role: .destructive) { discardActiveWorkout() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Completed sets will be discarded.")
        }
        .sheet(isPresented: $isShowingExercisesSheet) {
            AddExerciseSheetView(
                addedExercises: Set(workout.exercises),
                onAdd: { selection in
                    for exercise in selection {
                        workout.appendExercise(WorkoutExercise(exercise: exercise))
                        Log.persistence.debug("Exercise added to workout: \(exercise.name)")
                    }
                    isShowingExercisesSheet = false
                }
            )
        }
        .sheet(isPresented: $isShowingSummary) {
            WorkoutSummarySheet(workout: workout, unit: weightUnit, onSave: {
                workout.finish()
                context.insert(workout)
                restTimer.stop()
                do {
                    try context.save()
                    Log.workout.info("Workout saved: \(workout.name)")
                } catch {
                    Log.persistence.error("Failed to save workout: \(error.localizedDescription)")
                    errorHandler.show("Could not save your workout. Please try again.")
                }
                isShowingSummary = false
                dismiss()
            }, onCancel: {
                Log.workout.info("Summary cancelled")
                isShowingSummary = false
            })
        }
    }

    // MARK: - Subviews

    private func statView(_ value: String, label: String) -> some View {
        VStack {
            Text(value).font(.title3)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    /// Binding for the optional `end` date so DatePicker has a non-optional value.
    private var endDateBinding: Binding<Date> {
        Binding(
            get: { workout.end ?? Date.now },
            set: { workout.end = $0 }
        )
    }

    // MARK: - Actions

    private func discardActiveWorkout() {
        restTimer.stop()
        Log.workout.info("Workout cancelled")
        dismiss()
    }

    private func saveAndDismiss() {
        do {
            try context.save()
            Log.workout.info("Workout edits saved: \(workout.name)")
        } catch {
            Log.persistence.error("Failed to save workout edits: \(error.localizedDescription)")
            errorHandler.show("Could not save your changes. Please try again.")
        }
        context.autosaveEnabled = true
        dismiss()
    }

    private func rollbackAndDismiss() {
        context.rollback()
        context.autosaveEnabled = true
        dismiss()
    }

    private func deleteExercises(at offsets: IndexSet) {
        if mode == .editing {
            // In edit mode, exercises are managed objects — delete from context
            let sorted = workout.sortedExercises
            for index in offsets {
                context.delete(sorted[index])
            }
        }
        workout.removeExercises(at: offsets)
    }
}

#Preview("Active") {
    let preview = Preview()

    return NavigationStack {
        WorkoutEditorView(mode: .active, workout: Workout())
            .modelContainer(preview.container)
    }
}

#Preview("Editing") {
    let preview = Preview()

    return NavigationStack {
        WorkoutEditorView(mode: .editing, workout: Workout.sample[0])
            .modelContainer(preview.container)
    }
}
