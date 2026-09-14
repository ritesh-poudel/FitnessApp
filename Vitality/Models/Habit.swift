//
//  Habit.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

/// A tracked daily habit, spanning health and productivity routines.
struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var category: HabitCategory
    /// Times per day the habit should be completed.
    var dailyGoal: Int
    /// Completions logged so far today.
    var completedToday: Int
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: HabitCategory,
        dailyGoal: Int = 1,
        completedToday: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dailyGoal = max(1, dailyGoal)
        self.completedToday = completedToday
        self.createdAt = createdAt
    }

    /// Progress toward today's goal, clamped to 0...1.
    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(completedToday) / Double(dailyGoal), 1)
    }

    var isComplete: Bool {
        completedToday >= dailyGoal
    }

    mutating func logCompletion() {
        completedToday = min(completedToday + 1, AppConstants.Limits.maxDailyCompletions)
    }

    mutating func undoCompletion() {
        completedToday = max(completedToday - 1, 0)
    }

    mutating func resetForNewDay() {
        completedToday = 0
    }
}
