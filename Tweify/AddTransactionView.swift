//
//  AddTransactionView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    
    @State private var amount = ""
    @State private var description = ""
    @State private var transactionType = 0 // 0 for addition, 1 for deduction
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Transaction Type", selection: $transactionType) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .tag(0)
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                
                TextField("Description (optional)", text: $description)
            }
            .navigationTitle("New Transaction")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addTransaction()
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
    
    private func addTransaction() {
        withAnimation {
            let finalAmount = (Double(amount) ?? 0) * (transactionType == 1 ? -1 : 1)
            
            let transaction = Transaction(context: viewContext)
            transaction.id = UUID()
            transaction.amount = finalAmount
            transaction.date = Date()
            transaction.transactionDescription = description.isEmpty ? nil : description
            transaction.isDeduction = transactionType == 1
            transaction.goal = goal
            
            goal.amountSaved += finalAmount
            
            try? viewContext.save()
            dismiss()
        }
    }
}
