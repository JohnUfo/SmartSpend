//
//  SmartSpendApp.swift
//  SmartSpend
//
//  Created by Umidjon Tursunov on 23/08/2025.
//

import SwiftUI
import FirebaseCore

@main
struct SmartSpendApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("✅ App window appeared")
                }
                .preferredColorScheme(.dark)
        }
    }
}
