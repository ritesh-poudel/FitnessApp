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

    // MARK: - Onboarding

    /// False until onboarding has been completed once.
    func hasOnboarded() -> Bool {
        userDefaults.bool(forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
    }

    func setHasOnboarded(_ value: Bool) {
        userDefaults.set(value, forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
    }

    // MARK: - Profile

    /// The name shown in the greeting. Empty until onboarding collects it.
    func displayName() -> String {
        userDefaults.string(forKey: AppConstants.UserDefaultsKeys.displayName) ?? ""
    }

    func saveDisplayName(_ name: String) {
        userDefaults.set(name, forKey: AppConstants.UserDefaultsKeys.displayName)
    }

    func unitSystem() -> UnitSystem {
        guard let raw = userDefaults.string(forKey: AppConstants.UserDefaultsKeys.unitSystem),
              let units = UnitSystem(rawValue: raw) else {
            return .kilograms
        }
        return units
    }

    func saveUnitSystem(_ units: UnitSystem) {
        userDefaults.set(units.rawValue, forKey: AppConstants.UserDefaultsKeys.unitSystem)
    }

    /// What the person is working towards, chosen during onboarding.
    func trainingAim() -> TrainingAim {
        guard let raw = userDefaults.string(forKey: AppConstants.UserDefaultsKeys.trainingAim),
              let aim = TrainingAim(rawValue: raw) else {
            return .steadyHabit
        }
        return aim
    }

    func saveTrainingAim(_ aim: TrainingAim) {
        userDefaults.set(aim.rawValue, forKey: AppConstants.UserDefaultsKeys.trainingAim)
    }

    // MARK: - Reset

    /// Clears stored data and returns the app to its pre-onboarding state.
    func deleteAllData() {
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.habits)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.lastResetDate)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.displayName)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.unitSystem)
        userDefaults.removeObject(forKey: AppConstants.UserDefaultsKeys.trainingAim)
    }
}
