//
//  AddGoalView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

// Step enum to track progress
enum AddGoalStep: Int, CaseIterable {
    case name
    case goalAmount
    case savedAmount
}

struct AddGoalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var goalAmount = ""
    @State private var amountSaved = ""
    @State private var currentStep: AddGoalStep = .name
    @State private var slideTransition: AnyTransition = .slide
    
    private var isStepValid: Bool {
        switch currentStep {
        case .name:
            return !name.isEmpty
        case .goalAmount:
            return !goalAmount.isEmpty && (Double(goalAmount) ?? 0) > 0
        case .savedAmount:
            return true // Always valid as it can be 0
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case .name:
            return "What's your goal?"
        case .goalAmount:
            return "How much do you need?"
        case .savedAmount:
            return "Current progress"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(AddGoalStep.allCases, id: \.self) { step in
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top)
                
                // Main content
                Spacer()
                
                switch currentStep {
                case .name:
                    nameStep
                        .transition(slideTransition)
                case .goalAmount:
                    goalAmountStep
                        .transition(slideTransition)
                case .savedAmount:
                    savedAmountStep
                        .transition(slideTransition)
                }
                
                Spacer()
                
                // Navigation buttons
                navigationButtons
                    .padding(.bottom)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var nameStep: some View {
        VStack(spacing: 20) {
            Text("What's your goal's name?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            TextField("e.g., New MacBook", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var goalAmountStep: some View {
        VStack(spacing: 20) {
            Text("Nice going! How much is it?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            TextField("0.00", text: $goalAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .padding(.horizontal)
        }
    }
    
    private var savedAmountStep: some View {
        VStack(spacing: 20) {
            Text("How much have you saved?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("(We all start somewhere!)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("0.00", text: $amountSaved)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .padding(.horizontal)
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            if currentStep != .name {
                Button(action: previousStep) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(10)
                }
            }
            
            Button(action: nextStep) {
                HStack {
                    Text(currentStep == .savedAmount ? "Create Goal" : "Continue")
                    if currentStep != .savedAmount {
                        Image(systemName: "chevron.right")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isStepValid ? Color.blue : Color.blue.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!isStepValid)
        }
    }
    
    private func nextStep() {
        withAnimation {
            if currentStep == .savedAmount {
                addGoal()
            } else {
                slideTransition = .asymmetric(
                    insertion: .slide.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                )
                currentStep = AddGoalStep(rawValue: currentStep.rawValue + 1) ?? .name
            }
        }
    }
    
    private func previousStep() {
        withAnimation {
            slideTransition = .asymmetric(
                insertion: .slide.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            )
            currentStep = AddGoalStep(rawValue: currentStep.rawValue - 1) ?? .name
        }
    }
    
    private func addGoal() {
        withAnimation {
            let newGoal = Goal(context: viewContext)
            newGoal.id = UUID()
            newGoal.name = name
            newGoal.goalAmount = Double(goalAmount) ?? 0
            newGoal.amountSaved = Double(amountSaved) ?? 0
            
            try? viewContext.save()
            dismiss()
        }
    }
}

// Preview provider
struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        AddGoalView()
    }
}
