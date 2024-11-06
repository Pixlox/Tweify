//
//  TransactionRowView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct TransactionRowView: View {
    let transaction: Transaction
    
    var transactionDescription: String {
        transaction.transactionDescription ?? (transaction.isDeduction ? "Debit" : "Credit")
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transactionDescription)
                    .font(.headline)
                Text(transaction.date ?? Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.isDeduction ? "-" : "+")$\(abs(transaction.amount), specifier: "%.2f")")
                .foregroundColor(transaction.isDeduction ? .red : .green)
        }
    }
}

