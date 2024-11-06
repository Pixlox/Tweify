//
//  SettingsView.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool? // nil for system, true for dark, false for light
    @Environment(\.colorScheme) private var colorScheme // observe the system color scheme
    
    private var currentMode: ColorScheme {
        // Determine the mode: use system colorScheme if isDarkMode is nil
        if let isDarkMode = isDarkMode {
            return isDarkMode ? .dark : .light
        } else {
            return colorScheme
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: Binding(
                    get: { isDarkMode == nil ? 0 : (isDarkMode! ? 2 : 1) },
                    set: { newValue in
                        switch newValue {
                        case 0: isDarkMode = nil   // System mode
                        case 1: isDarkMode = false // Light mode
                        case 2: isDarkMode = true  // Dark mode
                        default: break
                        }
                    }
                )) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
            }
        }
        .preferredColorScheme(currentMode) // apply the preferred color scheme
        .navigationTitle("Settings")
    }
}

