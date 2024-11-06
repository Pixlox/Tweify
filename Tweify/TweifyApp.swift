//
//  TweifyApp.swift
//  Tweify
//
//  Created by Omar Hafeezullah on 27/10/2024.
//

import SwiftUI

@main
struct TweifyApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("isDarkMode") private var isDarkMode: Bool?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(isDarkMode.map { $0 ? .dark : .light })
        }
    }
}
