//
//  ContentView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingAddGoal = false
    @State private var goalToDelete: Goal?
    @State private var showingDeleteAlert = false
    @State private var sortOption: SortOption = .name
    @Environment(\.managedObjectContext) private var viewContext
    
    // Updated FetchRequest with SwiftUI SortDescriptor
    @FetchRequest private var goals: FetchedResults<Goal>
    
    // Sort options enum
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case amount = "Amount"
        case progress = "Progress"
        case pinned = "Pinned"
        
        var sortDescriptors: [SortDescriptor<Goal>] {
            switch self {
            case .name:
                return [
                    SortDescriptor(\Goal.isPinned, order: .reverse),
                    SortDescriptor(\Goal.name, order: .forward)
                ]
            case .amount:
                return [
                    SortDescriptor(\Goal.isPinned, order: .reverse),
                    SortDescriptor(\Goal.goalAmount, order: .reverse)
                ]
            case .progress:
                return [
                    SortDescriptor(\Goal.isPinned, order: .reverse),
                    SortDescriptor(\Goal.amountSaved, order: .reverse)
                ]
            case .pinned:
                return [
                    SortDescriptor(\Goal.isPinned, order: .reverse),
                    SortDescriptor(\Goal.name, order: .forward)
                ]
            }
        }
    }
    
    init() {
        // Initialize FetchRequest with default sort descriptors
        _goals = FetchRequest<Goal>(
            sortDescriptors: SortOption.pinned.sortDescriptors,
            animation: .default
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if goals.isEmpty {
                    VStack {
                        Text("No goals? Why not make one!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Button(action: { showingAddGoal.toggle() }) {
                            Label("Create Goal", systemImage: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                } else {
                    List {
                        ForEach(goals) { goal in
                            NavigationLink(destination: GoalDetailView(goal: goal)) {
                                GoalRowView(goal: goal)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(goal.isPinned ? "Unpin" : "Pin") {
                                    togglePin(goal)
                                }
                                .tint(.yellow)
                            }
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                goalToDelete = goals[index]
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tweify")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
                
                // Only show sort button if there are multiple goals
                if goals.count > 1 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    sortOption = option
                                    updateSortDescriptors(option)
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
            }
            .alert("Delete Goal", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let goal = goalToDelete {
                        deleteGoal(goal)
                    }
                }
            } message: {
                Text("Are you sure you want to delete '\(goalToDelete?.name ?? "this goal")'? This action cannot be undone.")
            }
        }
    }
    
    private func deleteGoal(_ goal: Goal) {
        withAnimation {
            viewContext.delete(goal)
            try? viewContext.save()
        }
    }
    
    private func togglePin(_ goal: Goal) {
        withAnimation {
            goal.isPinned.toggle()
            try? viewContext.save()
        }
    }
    
    private func updateSortDescriptors(_ option: SortOption) {
        goals.sortDescriptors = option.sortDescriptors
    }
}

#Preview {
    ContentView()
}
