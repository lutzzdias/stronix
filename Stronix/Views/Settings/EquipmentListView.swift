//
//  EquipmentListView.swift
//  Stronix
//
//  Created by Thiago Dias on 11/05/26.
//

import SwiftUI
import SwiftData

struct EquipmentListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Equipment.name) private var equipment: [Equipment]
    @State private var showCreateSheet: Bool = false
    @State private var editingEquipment: Equipment?
    @State private var pendingDelete: Equipment?
    @State private var isShowingDeleteConfirm = false

    var body: some View {
        List {
            ForEach(equipment) { eq in
                Button {
                    editingEquipment = eq
                } label: {
                    Label(eq.name, systemImage: eq.icon)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button("Delete", role: .destructive) {
                        pendingDelete = eq
                        isShowingDeleteConfirm = true
                    }
                }
            }
        }
        .navigationTitle("Equipment")
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
            EquipmentEditor(equipment: nil)
        }
        .sheet(item: $editingEquipment) { eq in
            EquipmentEditor(equipment: eq)
        }
        .alert("Delete equipment?", isPresented: $isShowingDeleteConfirm, presenting: pendingDelete) { eq in
            Button("Delete", role: .destructive) {
                // Capture before deleting; a deleted model reads back as defaults.
                let name = eq.name
                modelContext.delete(eq)
                Log.persistence.info("Equipment deleted: \(name)")
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("Exercises using this equipment will have it cleared.")
        }
    }
}

#Preview {
    let preview = Preview()

    return NavigationStack {
        EquipmentListView()
    }
    .modelContainer(preview.container)
}
