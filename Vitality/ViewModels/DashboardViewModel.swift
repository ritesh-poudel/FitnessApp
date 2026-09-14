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

    /// The one focus session that may be running at a time.
    private(set) var activeSession: FocusSession?

    private let storage: StorageService
    private let liveActivity: LiveActivityService
    /// Fires when the active session reaches its end date.
    private var completionTask: Task<Void, Never>?

    init(storage: StorageService = .shared, liveActivity: LiveActivityService = .shared) {
        self.storage = storage
        self.liveActivity = liveActivity
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
        await syncLiveActivity(with: habits[index])
    }

    func undoCompletion(for habit: Habit) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].undoCompletion()
        await persist()
        await syncLiveActivity(with: habits[index])
    }

    /// Pushes a habit's new count to the Live Activity when it is the one being timed.
    private func syncLiveActivity(with habit: Habit) async {
        guard let session = activeSession, session.habitID == habit.id else { return }
        await liveActivity.update(
            session: session,
            completedToday: habit.completedToday,
            dailyGoal: habit.dailyGoal
        )
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
        await cancelSession()
        habits = []
        await storage.deleteAllData()
    }

    // MARK: - Focus Timer

    func isRunningSession(for habit: Habit) -> Bool {
        activeSession?.habitID == habit.id
    }

    /// Starts a focus session for `habit`, replacing any session already running.
    func startSession(for habit: Habit, duration: TimeInterval = FocusSession.defaultDuration) async {
        if activeSession != nil {
            await cancelSession()
        }

        let session = FocusSession(
            habitID: habit.id,
            habitTitle: habit.title,
            category: habit.category,
            duration: duration
        )
        activeSession = session

        liveActivity.start(
            session: session,
            completedToday: habit.completedToday,
            dailyGoal: habit.dailyGoal
        )

        scheduleCompletion(for: session)
    }

    /// Stops the running session without logging a completion.
    func cancelSession() async {
        completionTask?.cancel()
        completionTask = nil
        activeSession = nil
        await liveActivity.end()
    }

    /// Sleeps until the session's end date, then logs the completion it earned.
    private func scheduleCompletion(for session: FocusSession) {
        completionTask?.cancel()
        completionTask = Task { [weak self] in
            let remaining = session.remaining()
            try? await Task.sleep(for: .seconds(remaining))
            guard !Task.isCancelled else { return }
            await self?.finish(session)
        }
    }

    /// Called when the countdown reaches zero: credits the habit and clears the activity.
    private func finish(_ session: FocusSession) async {
        // Ignore a stale task whose session has already been replaced or cancelled.
        guard activeSession?.id == session.id else { return }

        completionTask = nil
        activeSession = nil

        if let habit = habits.first(where: { $0.id == session.habitID }) {
            await logCompletion(for: habit)
        }

        await liveActivity.end()
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
