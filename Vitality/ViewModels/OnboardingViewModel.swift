//
//  OnboardingViewModel.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation
import SwiftUI

/// Drives the five onboarding steps and writes the result to storage.
@MainActor
@Observable
final class OnboardingViewModel {
    /// The five steps, in order.
    enum Step: Int, CaseIterable {
        case welcome, metrics, aim, comfort, summary

        /// The primary button's label for this step.
        var callToAction: String {
            switch self {
            case .welcome: "Get started"
            case .summary: "Enter Baseline"
            default: "Continue"
            }
        }
    }

    private(set) var step: Step = .welcome
    /// +1 when travelling forwards, -1 when going back. Drives the slide direction.
    private(set) var direction: Double = 1

    var selectedMetrics = TrackableMetric.defaultSelection
    var aim: TrainingAim = .steadyHabit
    var biggerText = false
    var strongerLabels = false

    /// The readiness figure, counted up on the final step.
    private(set) var score = 0

    private(set) var toast: String?
    private var toastTask: Task<Void, Never>?
    private var scoreTask: Task<Void, Never>?

    private let storage: StorageService

    /// The figure the count-up settles on.
    static let finalScore = 84

    init(storage: StorageService = .shared) {
        self.storage = storage
    }

    // MARK: - Derived

    var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    var stepCount: String {
        "Step \(step.rawValue + 1) of \(Step.allCases.count)"
    }

    var backLabel: String {
        step == .welcome ? "I have an account" : "‹ Back"
    }

    /// The right-aligned footnote, which reflects the current step's choice.
    var footnote: String {
        switch step {
        case .welcome: "Takes about a minute"
        case .metrics: "\(selectedMetrics.count) selected"
        case .aim: aim.label
        case .comfort: biggerText ? "Bigger text on" : "Standard text"
        case .summary: "All set"
        }
    }

    var pickNote: String {
        "\(selectedMetrics.count) on your Today screen. You can add more later."
    }

    /// The three lines confirming what was chosen.
    var summaryLines: [(key: String, value: String)] {
        [
            ("Tracking", "\(selectedMetrics.count) metrics"),
            ("Your aim", aim.label),
            ("Reading", biggerText ? "Bigger text" : "Standard text")
        ]
    }

    /// The sample chart on the welcome step.
    var welcomeBars: [(height: Double, isAccent: Bool)] {
        [46, 72, 58, 91, 66, 38, 79].enumerated().map { index, height in
            (height / 100, index == 6)
        }
    }

    // MARK: - Actions

    func toggle(_ metric: TrackableMetric) {
        if selectedMetrics.contains(metric) {
            selectedMetrics.remove(metric)
        } else {
            selectedMetrics.insert(metric)
        }
    }

    /// Advances a step, or finishes. Returns true when onboarding is complete.
    func advance() async -> Bool {
        // The one gate in the flow: at least one metric must be tracked.
        if step == .metrics && selectedMetrics.isEmpty {
            flash("Pick at least one to track")
            return false
        }

        if step == .summary {
            await finish()
            return true
        }

        guard let next = Step(rawValue: step.rawValue + 1) else { return false }
        direction = 1
        withAnimation(Theme.Motion.push) {
            step = next
        }

        if next == .summary {
            countUpScore()
        }
        return false
    }

    func goBack() {
        guard step != .welcome else {
            flash("Sign-in comes next")
            return
        }
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        direction = -1
        withAnimation(Theme.Motion.push) {
            step = previous
        }
    }

    /// Writes the chosen setup, so the app opens configured rather than seeded.
    private func finish() async {
        await storage.saveUnitSystem(.kilograms)
        await storage.setHasOnboarded(true)

        let habits = Self.habits(for: selectedMetrics, aim: aim)
        try? await storage.saveHabits(habits)
    }

    /// Builds the starting habits from the chosen metrics. The aim sets how
    /// demanding each daily goal is.
    private static func habits(for metrics: Set<TrackableMetric>, aim: TrainingAim) -> [Habit] {
        // "Just keep records" means no targets, so every goal is a single log.
        let demanding = aim == .trainForSomething

        return TrackableMetric.allCases.filter(metrics.contains).map { metric in
            switch metric {
            case .steps:
                Habit(title: "Move every day", category: .health, dailyGoal: 1)
            case .sleep:
                Habit(title: "Sleep seven hours", category: .health, dailyGoal: 1)
            case .heartRate:
                Habit(title: "Check resting heart rate", category: .health, dailyGoal: 1)
            case .workouts:
                Habit(title: "Workout", category: .health, dailyGoal: demanding ? 2 : 1)
            case .food:
                Habit(title: "Log meals", category: .health, dailyGoal: demanding ? 3 : 1)
            case .weight:
                Habit(title: "Weigh in", category: .health, dailyGoal: 1)
            case .bloodPressure:
                Habit(title: "Take a reading", category: .health, dailyGoal: 1)
            case .howYouFeel:
                Habit(title: "Check in with how you feel", category: .health, dailyGoal: 1)
            }
        }
    }

    // MARK: - Score Count-Up

    /// Counts the readiness figure up from zero, as the design does on arrival.
    private func countUpScore() {
        scoreTask?.cancel()
        score = 0
        scoreTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(24))
                guard !Task.isCancelled, let self else { return }

                let next = self.score + 3
                if next >= Self.finalScore {
                    self.score = Self.finalScore
                    return
                }
                self.score = next
            }
        }
    }

    // MARK: - Toast

    func flash(_ message: String) {
        toastTask?.cancel()
        withAnimation(Theme.Motion.state) {
            toast = message
        }
        toastTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withAnimation(Theme.Motion.state) {
                self?.toast = nil
            }
        }
    }
}
