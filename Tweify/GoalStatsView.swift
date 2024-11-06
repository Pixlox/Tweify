import SwiftUI
import CoreData
import Charts

struct GoalStatsView: View {
    @ObservedObject var goal: Goal
    
    // Last 30 days of transactions
    private var last30DaysTransactions: [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -30, to: Date())!
        
        let transactions = (goal.transactions?.allObjects as? [Transaction] ?? [])
            .filter { $0.date ?? Date() >= startDate }
            .sorted { ($0.date ?? Date()) < ($1.date ?? Date()) }
        
        var runningTotal = goal.amountSaved - transactions.reduce(0) { $0 + $1.amount }
        
        var dailyAmounts: [(date: Date, amount: Double)] = []
        var currentDate = startDate
        
        while currentDate <= Date() {
            let dayTransactions = transactions.filter {
                calendar.isDate($0.date ?? Date(), inSameDayAs: currentDate)
            }
            
            for transaction in dayTransactions {
                runningTotal += transaction.amount
            }
            
            dailyAmounts.append((date: currentDate, amount: runningTotal))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dailyAmounts
    }
    
    private var weeklyStats: (thisWeek: Double, lastWeek: Double) {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today)!
        
        let transactions = goal.transactions?.allObjects as? [Transaction] ?? []
        
        let thisWeekTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= weekAgo && date <= today
        }
        
        let lastWeekTransactions = transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            return date >= twoWeeksAgo && date < weekAgo
        }
        
        return (
            thisWeek: thisWeekTransactions.reduce(0) { $0 + $1.amount },
            lastWeek: lastWeekTransactions.reduce(0) { $0 + $1.amount }
        )
    }
    
    private var insightMessage: String {
        let (thisWeek, lastWeek) = weeklyStats
        let increaseThreshold: Double = 1.05  // was 1.2
        let decreaseThreshold: Double = 0.95  // was 0.8
        
        // Compare the total amounts directly
        if thisWeek > 0 && lastWeek > 0 {
            if thisWeek > lastWeek * increaseThreshold {
                return "You're putting more money in your goal this week! 🎉"
            } else if thisWeek < lastWeek * decreaseThreshold {
                return "You're putting less money in your goal this week. 📉"
            }
        } else if thisWeek < 0 && lastWeek < 0 {
            if abs(thisWeek) < abs(lastWeek) * decreaseThreshold {
                return "You're spending less money from your goal this week. 👍"
            } else if abs(thisWeek) > abs(lastWeek) * increaseThreshold {
                return "You're spending more money from your goal this week. ⚠️"
            }
        }
        
        return "Your spending patterns are stable this week. 📊"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Progress:")
                .font(.headline)
            
            Chart {
                ForEach(last30DaysTransactions, id: \.date) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(Color.blue)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Amount", dataPoint.amount)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        let amount = value.as(Double.self) ?? 0
                        Text("$\(abs(amount), specifier: "%.0f")")
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Insight:")
                    .font(.headline)
                Text(insightMessage)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
