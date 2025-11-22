//
//  LocalizationManager.swift
//  SmartSpend
//
//  Created on 11/22/2025.
//

import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language {
        didSet {
            // Update the bundle when language changes
            if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                self.bundle = bundle
            } else {
                self.bundle = Bundle.main
            }
        }
    }
    
    private var bundle: Bundle = Bundle.main
    
    private init() {
        // Load saved language or default to English
        self.currentLanguage = DataManager.shared.user.language
        
        // Set up the bundle for the current language
        if let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        }
    }
    
    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        DataManager.shared.updateLanguage(language)
    }
}
