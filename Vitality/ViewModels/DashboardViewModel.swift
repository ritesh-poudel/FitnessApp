//
//  DashboardViewModel.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var habits: [Habit] = []

    private let storage: StorageService

    init(storage: StorageService = .shared) {
        self.storage = storage
    }

    // MARK: - Derived State

    func habits(in category: HabitCategory) -> [Habit] {
        habits.filter { $0.category == category }
    }

    /// Share of today's goals met across every habit, 0...1.
    var dayProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return habits.reduce(0) { $0 + $1.progress } / Double(habits.count)
    }

    var completedCount: Int {
        habits.filter(\.isComplete).count
    }

    // MARK: - Lifecycle

    func load() async {
        habits = (try? await storage.loadHabits()) ?? []
        if habits.isEmpty {
            habits = Self.starterHabits
            await persist()
        }
        await rolloverIfNeeded()
    }

    /// Clears today's counts when the calendar day has changed since the last launch.
    private func rolloverIfNeeded() async {
        let now = Date()
        let last = await storage.lastResetDate()
        guard last == nil || !Calendar.current.isDate(last!, inSameDayAs: now) else { return }

        for index in habits.indices {
            habits[index].resetForNewDay()
        }
        await storage.recordReset(on: now)
        await persist()
    }

    // MARK: - Actions

    func logCompletion(for habit: Habit) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].logCompletion()
        await persist()
    }

    func undoCompletion(for habit: Habit) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].undoCompletion()
        await persist()
    }

    func add(_ habit: Habit) async {
        habits.append(habit)
        await persist()
    }

    func delete(_ habit: Habit) async {
        habits.removeAll { $0.id == habit.id }
        await persist()
    }

    func resetAllData() async {
        habits = []
        await storage.deleteAllData()
    }

    private func persist() async {
        try? await storage.saveHabits(habits)
    }

    // MARK: - Seed Data

    private static var starterHabits: [Habit] {
        [
            Habit(title: "Drink water", category: .health, dailyGoal: 8),
            Habit(title: "Move for 30 minutes", category: .health, dailyGoal: 1),
            Habit(title: "Sleep by 11pm", category: .health, dailyGoal: 1),
            Habit(title: "Deep work session", category: .productivity, dailyGoal: 3),
            Habit(title: "Inbox to zero", category: .productivity, dailyGoal: 1)
        ]
    }
}
