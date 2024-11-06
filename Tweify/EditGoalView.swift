//
//  EditGoalView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct EditGoalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var goal: Goal
    
    @State private var name: String
    @State private var goalAmount: String
    
    init(goal: Goal) {
        self.goal = goal
        _name = State(initialValue: goal.name ?? "")
        _goalAmount = State(initialValue: String(goal.goalAmount))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Name")) {
                    TextField("New MacBook?", text: $name)
                }
                
                Section(header: Text("Goal Amount")) {
                    TextField("How much?", text: $goalAmount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || goalAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        withAnimation {
            goal.name = name
            goal.goalAmount = Double(goalAmount) ?? 0
            
            try? viewContext.save()
            dismiss()
        }
    }
}
