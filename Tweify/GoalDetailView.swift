//
//  GoalDetailView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct GoalDetailView: View {
    @ObservedObject var goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTransaction = false
    @State private var showingEditGoal = false
    
    var transactions: [Transaction] {
        (goal.transactions?.allObjects as? [Transaction] ?? [])
            .sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    var body: some View {
        List {
            Section(header: Text("Goal Info")) {
                VStack(alignment: .leading, spacing: 8) {
                    GoalRowView(goal: goal)
                }
                .padding(.vertical, 8)
            }
            
            Section {
                Button(action: { showingAddTransaction.toggle() }) {
                    Label("Add Transaction", systemImage: "plus.circle")
                }
                
                Button(action: { showingEditGoal.toggle() }) {
                    Label("Edit Goal", systemImage: "pencil")
                }
            }
            
            Section(header: Text("Statistics")) {
                GoalStatsView(goal: goal)
            }
            
            Section(header: Text("GoalSense")) {
                GoalPredictionView(goal: goal)
            }
            
            Section(header: Text("Transactions")) {
                if transactions.isEmpty {
                    Text("No transactions yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(transactions, id: \.self) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
        }
        .navigationTitle(goal.name ?? "Goal Details")
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(goal: goal)
        }
        .sheet(isPresented: $showingEditGoal) {
            EditGoalView(goal: goal)
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let transaction = transactions[index]
                goal.amountSaved -= transaction.amount
                viewContext.delete(transaction)
            }
            try? viewContext.save()
        }
    }
}
