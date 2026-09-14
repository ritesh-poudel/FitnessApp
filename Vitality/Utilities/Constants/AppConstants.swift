//
//  AppConstants.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

enum AppConstants {
    // MARK: - App Info

    static let appName = "Vitality"
    static let version = "1.0.0"
    static let websiteURL = URL(string: "https://apple.com")!

    // MARK: - User Defaults Keys

    enum UserDefaultsKeys {
        static let habits = "savedHabits"
        static let lastResetDate = "lastResetDate"
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let displayName = "displayName"
        static let unitSystem = "unitSystem"
    }

    // MARK: - Limits

    enum Limits {
        static let maxDailyCompletions = 99
        static let maxDailyGoal = 24
    }
}
