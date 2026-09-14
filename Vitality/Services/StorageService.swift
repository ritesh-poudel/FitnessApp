//
//  StorageService.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

/// Service for persisting tracked habits.
actor StorageService {
    static let shared = StorageService()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - Habit Storage

    func saveHabits(_ habits: [Habit]) throws {
        let data = try encoder.encode(habits)
        userDefaults.set(data, forKey: AppConstants.UserDefaultsKeys.habits)
    }

    func loadHabits() throws -> [Habit] {
        guard let data = userDefaults.data(forKey: AppConstants.UserDefaultsKeys.habits) else {
            return []
        }
        return try decoder.decode([Habit].self, from: data)
    }

    // MARK: - Daily Reset

    /// The day the habit counts were last rolled over, if any.
    func lastResetDate() -> Date? {
        userDefaults.object(forKey: AppConstants.UserDefaultsKeys.lastResetDate) as? Date
    }

    func recordReset(on date: Date = Date()) {
        userDefaults.set(date, forKey: AppConstants.UserDefaultsKeys.lastResetDate)
    }

    // MARK: - Reset

    func deleteAllData() {
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.habits)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.lastResetDate)
    }
}
