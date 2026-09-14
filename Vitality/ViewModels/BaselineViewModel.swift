//
//  BaselineViewModel.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation
import SwiftUI

/// Drives the Baseline screens. Habits, focus sessions and settings are real
/// stored state; the health metrics are sample data (see `MetricSample`).
@MainActor
@Observable
final class BaselineViewModel {
    // MARK: - Navigation

    enum Tab: String, CaseIterable, Identifiable {
        case today, trends, plan, goals, profile

        var id: String { rawValue }

        var label: String {
            switch self {
            case .today: "Today"
            case .trends: "Trends"
            case .plan: "Plan"
            case .goals: "Goals"
            case .profile: "You"
            }
        }
    }

    var tab: Tab = .today
    /// The metric pushed over the tab content, if any.
    var detail: MetricSample?
    var isSheetPresented = false
    var range: Range = .week

    enum Range: String, CaseIterable, Identifiable {
        case day = "Day", week = "Week", month = "Month"
        var id: String { rawValue }
    }

    // MARK: - Logged State

    private(set) var steps = 8420
    private(set) var water = 2
    private(set) var readiness = 84

    /// Glasses of water that count as a full day.
    static let waterGoal = 6

    // MARK: - Settings

    var largeType = false
    var strongContrast = false
    var reduceMotion = false
    var units: UnitSystem = .kilograms
    /// What the person said they were working towards during onboarding.
    /// Shapes the generated readings.
    private(set) var aim: TrainingAim = .steadyHabit

    var morningReminder = true
    var waterReminder = true
    var windDownReminder = false

    /// The design scales the whole screen up rather than restyling it.
    var typeScale: CGFloat { largeType ? 1.14 : 1 }

    // MARK: - Toast

    private(set) var toast: String?
    private var toastTask: Task<Void, Never>?

    // MARK: - Habits and Focus

    private(set) var habits: [Habit] = []
    private(set) var activeSession: FocusSession?
    /// Seconds left in the focus block.
    private(set) var secondsRemaining = Int(FocusSession.defaultDuration)
    private(set) var isFocusRunning = false
    private(set) var completedPomodoros = 1

    /// Focus blocks that make up a full day.
    static let pomodoroTarget = 4

    private let storage: StorageService
    private let liveActivity: LiveActivityService
    private var tickTask: Task<Void, Never>?

    init(storage: StorageService = .shared, liveActivity: LiveActivityService? = nil) {
        self.storage = storage
        self.liveActivity = liveActivity ?? .shared
    }

    // MARK: - Lifecycle

    func load() async {
        units = await storage.unitSystem()
        aim = await storage.trainingAim()
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

    private func persist() async {
        try? await storage.saveHabits(habits)
    }

    /// Clears every stored habit and its progress. Health metrics are sample
    /// data and are not stored, so they are unaffected.
    func resetAllData() async {
        await resetFocus()
        habits = []
        await storage.deleteAllData()
        flash("All data reset")
    }

    // MARK: - Today

    var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case ..<12: "Good morning, Sam"
        case 12..<18: "Good afternoon, Sam"
        default: "Good evening, Sam"
        }
    }

    /// The seven-day readiness trend. Today's column is live.
    var readinessBars: [ChartBar] {
        let history = [64.0, 78, 71, 92, 80, 55, Double(readiness)]
        return history.enumerated().map { index, value in
            ChartBar(
                day: "",
                caption: "",
                fraction: value / 100 * 0.9,
                isToday: index == history.count - 1
            )
        }
    }

    /// The six headline tiles.
    var tiles: [MetricTile] {
        let kilograms = units == .kilograms
        return [
            MetricTile(metric: .steps, label: "Steps", value: steps.formatted(.number),
                       unit: "steps", delta: "+320 vs usual"),
            MetricTile(metric: .sleep, label: "Sleep", value: "7h 10m",
                       unit: "", delta: "50m above average"),
            MetricTile(metric: .restingHeart, label: "Resting heart", value: "62",
                       unit: "bpm", delta: "Down 2 this month"),
            MetricTile(metric: .food, label: "Food", value: "1,840",
                       unit: "kcal", delta: "\(water) of \(Self.waterGoal) glasses"),
            MetricTile(metric: .workouts, label: "Workouts", value: "3",
                       unit: "this week", delta: "One from your goal"),
            MetricTile(metric: .weight, label: "Weight", value: kilograms ? "71.4" : "157.4",
                       unit: kilograms ? "kg" : "lb", delta: "Down 0.5 in 2 weeks")
        ]
    }

    /// The secondary metrics, shown as rows rather than tiles.
    var secondaryRows: [MetricTile] {
        [
            MetricTile(metric: .bloodPressure, label: "Blood pressure",
                       value: "118/76", unit: "mmHg", delta: ""),
            MetricTile(metric: .bloodOxygen, label: "Blood oxygen",
                       value: "98", unit: "%", delta: ""),
            MetricTile(metric: .mood, label: "How you feel",
                       value: "Good", unit: "today", delta: ""),
            MetricTile(metric: .cycle, label: "Cycle",
                       value: "Day 17", unit: "of 29", delta: "")
        ]
    }

    // MARK: - Quick Logging

    /// The actions offered by the "Log something" sheet.
    var sheetActions: [SheetAction] {
        [
            SheetAction(label: "A 20-minute walk", sublabel: "Adds about 1,900 steps") { [weak self] in
                self?.logWalk()
            },
            SheetAction(label: "A glass of water",
                        sublabel: "\(water) of \(Self.waterGoal) so far today") { [weak self] in
                self?.logWater()
            },
            SheetAction(label: "How you feel", sublabel: "Takes five seconds") { [weak self] in
                self?.isSheetPresented = false
                self?.flash("Thanks for checking in")
            }
        ]
    }

    func logWalk() {
        isSheetPresented = false
        withAnimation(Theme.Motion.progress) {
            steps += 1900
            readiness = min(99, readiness + 2)
        }
        flash("Walk logged — step goal met")
    }

    func logWater() {
        isSheetPresented = false
        withAnimation(Theme.Motion.progress) {
            water += 1
        }
        flash("Water logged. Nice.")
    }

    // MARK: - Goals

    /// Progress toward the step goal, 0...1.
    var moveProgress: Double { min(Double(steps) / 10_000, 1) }
    /// Progress toward the water goal, 0...1.
    var waterProgress: Double { min(Double(water) / Double(Self.waterGoal), 1) }
    /// Sleep is not yet measured, so this is a fixed sample figure.
    var sleepProgress: Double { 0.62 }

    // MARK: - Trends

    var weekLines: [WeekLine] {
        [
            WeekLine(numeral: "5", color: Theme.accent,
                     text: "days you moved before noon — your best run since June."),
            WeekLine(numeral: "7h09", color: Theme.text,
                     text: "average sleep. Steady nights are doing most of the work here."),
            WeekLine(numeral: "−2", color: Theme.text,
                     text: "bpm resting heart rate over the month. Fitness is building.")
        ]
    }

    var comparisonRows: [(metric: String, thisWeek: String, lastWeek: String)] {
        [
            ("Steps / day", "7,846", "7,010"),
            ("Sleep / night", "7h 09m", "6h 41m"),
            ("Workouts", "3", "2"),
            ("Resting heart", "63 bpm", "65 bpm"),
            ("Good-mood days", "4", "3")
        ]
    }

    // MARK: - Plan

    /// Habits stand in as the day's checklist, so ticking one is real, stored progress.
    var tasks: [Habit] { habits }

    var completedTaskCount: Int { habits.filter(\.isComplete).count }

    var taskProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(habits.count)
    }

    var planSummary: String {
        "\(completedTaskCount) of \(habits.count) done · next block \(TimeBlock.nextUp)"
    }

    var clock: String {
        String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    var focusNote: String {
        isFocusRunning
            ? "Deep work. Notifications are paused."
            : "A 25-minute block, then a short break."
    }

    var focusLabel: String {
        if isFocusRunning { return "Pause" }
        return secondsRemaining < Int(FocusSession.defaultDuration) ? "Resume" : "Start focus"
    }

    var pomodoroNote: String {
        "\(completedPomodoros) of \(Self.pomodoroTarget) sessions today"
    }

    var streaks: [(value: String, label: String)] {
        [("12", "Day streak"), ("38", "Focus hours"), ("86%", "Tasks kept")]
    }

    // MARK: - Habit Actions

    func toggle(_ habit: Habit) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }

        if habits[index].isComplete {
            habits[index].undoCompletion()
            flash("Back on the list")
        } else {
            habits[index].logCompletion()
            flash("Ticked off — \(habits[index].title)")
        }

        await persist()
        await syncLiveActivity(with: habits[index])
    }

    private func syncLiveActivity(with habit: Habit) async {
        guard let session = activeSession, session.habitID == habit.id else { return }
        await liveActivity.update(
            session: session,
            completedToday: habit.completedToday,
            dailyGoal: habit.dailyGoal
        )
    }

    // MARK: - Focus Timer

    /// Starts or pauses the focus block. A running block drives a Live Activity
    /// against the first productivity habit, so the countdown appears on the
    /// Lock Screen and in the Dynamic Island.
    func toggleFocus() async {
        if isFocusRunning {
            tickTask?.cancel()
            tickTask = nil
            isFocusRunning = false
            await liveActivity.end()
            activeSession = nil
            flash("Paused")
        } else {
            isFocusRunning = true
            await startLiveActivity()
            startTicking()
            flash("Focus started")
        }
    }

    func resetFocus() async {
        tickTask?.cancel()
        tickTask = nil
        isFocusRunning = false
        secondsRemaining = Int(FocusSession.defaultDuration)
        await liveActivity.end()
        activeSession = nil
    }

    /// Attaches the session to a productivity habit so a finished block credits it.
    private func startLiveActivity() async {
        guard let habit = habits.first(where: { $0.category == .productivity }) else { return }

        let session = FocusSession(
            habitID: habit.id,
            habitTitle: habit.title,
            category: habit.category,
            duration: TimeInterval(secondsRemaining)
        )
        activeSession = session

        liveActivity.start(
            session: session,
            completedToday: habit.completedToday,
            dailyGoal: habit.dailyGoal
        )
    }

    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard let self else { return }

                if self.secondsRemaining <= 1 {
                    await self.finishFocusBlock()
                    return
                }
                self.secondsRemaining -= 1
            }
        }
    }

    /// Credits the habit the block was attached to, then resets the timer.
    private func finishFocusBlock() async {
        tickTask = nil
        isFocusRunning = false
        secondsRemaining = Int(FocusSession.defaultDuration)
        completedPomodoros = min(Self.pomodoroTarget, completedPomodoros + 1)

        if let session = activeSession,
           let habit = habits.first(where: { $0.id == session.habitID }) {
            await toggleCompletionCredit(for: habit)
        }

        await liveActivity.end()
        activeSession = nil
        flash("Session done — stand up and stretch")
    }

    /// Logs one completion without the toast that `toggle` shows.
    private func toggleCompletionCredit(for habit: Habit) async {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].logCompletion()
        await persist()
    }

    // MARK: - Toast

    func flash(_ message: String) {
        toastTask?.cancel()
        withAnimation(Theme.Motion.state) {
            toast = message
        }
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.2))
            guard !Task.isCancelled else { return }
            withAnimation(Theme.Motion.state) {
                self?.toast = nil
            }
        }
    }

    // MARK: - Seed Data

    private static var starterHabits: [Habit] {
        [
            Habit(title: "Morning walk", category: .health, dailyGoal: 1, completedToday: 1),
            Habit(title: "Deep work block", category: .productivity, dailyGoal: 1),
            Habit(title: "Two glasses of water", category: .health, dailyGoal: 1),
            Habit(title: "Reply to Priya", category: .productivity, dailyGoal: 1, completedToday: 1),
            Habit(title: "Lights out by 23:00", category: .health, dailyGoal: 1)
        ]
    }
}

// MARK: - View Data

/// One of the six headline tiles, or a secondary row.
struct MetricTile: Identifiable {
    var id: String { metric.rawValue }
    let metric: MetricSample
    let label: String
    let value: String
    let unit: String
    let delta: String
}

/// A numeral-led line on the Trends screen.
struct WeekLine: Identifiable {
    let id = UUID()
    let numeral: String
    let color: Color
    let text: String
}

/// One row in the quick-log sheet.
struct SheetAction: Identifiable {
    let id = UUID()
    let label: String
    let sublabel: String
    let run: () -> Void
}

extension Habit {
    /// The checklist subtitle shown on the Plan tab.
    var planSublabel: String {
        switch title {
        case "Morning walk": "20 minutes before the first meeting"
        case "Deep work block": "Quarterly review draft"
        case "Two glasses of water": "Before lunch"
        case "Reply to Priya": "Short answer is fine"
        case "Lights out by 23:00": "Protects tomorrow's readiness"
        default: dailyGoal > 1 ? "\(completedToday) of \(dailyGoal) today" : ""
        }
    }

    /// The tag shown at the trailing edge of a checklist row.
    var planTag: String {
        switch title {
        case "Deep work block": "Focus"
        case "Reply to Priya": "Admin"
        default: category == .health ? "Health" : "Focus"
        }
    }
}
