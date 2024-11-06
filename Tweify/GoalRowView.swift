//
//  GoalRowView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct GoalRowView: View {
    @ObservedObject var goal: Goal
    
    var progress: Double {
        guard goal.goalAmount > 0 else { return 0 }
        return goal.amountSaved / goal.goalAmount
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if goal.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.yellow)
                }
                
                Text(goal.name ?? "Unnamed Goal")
                    .font(.headline)
            }
            
            HStack {
                Text("$\(goal.amountSaved, specifier: "%.2f") / $\(goal.goalAmount, specifier: "%.2f")")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption)
            }
            
            ProgressView(value: progress)
                .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

