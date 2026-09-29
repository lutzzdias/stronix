//
//  MuscleGroupListView.swift
//  Stronix
//

import SwiftUI
import SwiftData

struct MuscleGroupListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ErrorHandler.self) private var errorHandler

    @Query(sort: \MuscleGroup.name) private var muscleGroups: [MuscleGroup]
    @State private var showCreateSheet: Bool = false
    @State private var editingMuscleGroup: MuscleGroup?
    @State private var pendingDelete: MuscleGroup?
    @State private var isShowingDeleteConfirm = false

    var body: some View {
        List {
            ForEach(muscleGroups) { group in
                Button {
                    editingMuscleGroup = group
                } label: {
                    Text(group.name)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", role: .destructive) {
                        pendingDelete = group
                        isShowingDeleteConfirm = true
                    }
                }
            }
        }
        .navigationTitle("Muscles")
        .toolbar {
            ToolbarItem {
                Button {
                    showCreateSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            MuscleGroupEditor(muscleGroup: nil)
        }
        .sheet(item: $editingMuscleGroup) { group in
            MuscleGroupEditor(muscleGroup: group)
        }
        .alert("Delete muscle?", isPresented: $isShowingDeleteConfirm, presenting: pendingDelete) { group in
            Button("Delete", role: .destructive) {
                // Capture before deleting; a deleted model reads back as defaults.
                let name = group.name
                modelContext.delete(group)
                do {
                    try modelContext.save()
                    Log.persistence.info("Muscle deleted: \(name)")
                } catch {
                    Log.persistence.error("Failed to delete muscle: \(error.localizedDescription)")
                    errorHandler.show("Could not delete \(name). Please try again.")
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("Exercises using this muscle will have it cleared.")
        }
    }
}

#Preview {
    let preview = Preview()

    return NavigationStack {
        MuscleGroupListView()
    }
    .modelContainer(preview.container)
    .environment(ErrorHandler())
}
