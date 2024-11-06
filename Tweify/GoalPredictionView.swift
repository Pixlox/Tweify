//
//  GoalPredictionView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 7/11/2024.
//


import SwiftUI
import CoreData

struct GoalPredictionView: View {
    @ObservedObject var goal: Goal
    @State private var dotCount = 0
    
    private var predictionText: String {
        
        // Check if the goal amount has been reached
        if goal.amountSaved >= goal.goalAmount {
            return "Congrats! You've reached your goal! 🎉"
        }
        
        guard let transactions = goal.transactions?.allObjects as? [Transaction],
              !transactions.isEmpty else {
            return "Add some transactions to see when you might reach your goal."
        }
        
        // Calculate average daily contribution
        let calendar = Calendar.current
        let sortedTransactions = transactions.sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
        
        guard let firstDate = sortedTransactions.first?.date,
              let lastDate = sortedTransactions.last?.date else {
            return "Insufficient data to make a prediction."
        }
        
        let daysBetween = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 1
        let totalContribution = transactions.reduce(0.0) { $0 + $1.amount }
        let averageDailyContribution = totalContribution / Double(max(daysBetween, 1))
        
        // If average daily contribution is zero or negative
        guard averageDailyContribution > 0 else {
            return "Based on current patterns, you'll need to save more to reach your goal."
        }
        
        // Calculate remaining amount and days needed
        let remainingAmount = goal.goalAmount - goal.amountSaved
        let daysNeeded = Int(ceil(remainingAmount / averageDailyContribution))
        
        // Calculate predicted completion date
        let predictedDate = calendar.date(byAdding: .day, value: daysNeeded, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        return "Based on your saving patterns, you might reach your goal around \(dateFormatter.string(from: predictedDate))."
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                
                Text(predictionText)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .frame(maxWidth: .infinity, alignment: .center) // Centering the outer VStack
        .padding()
    }
}
