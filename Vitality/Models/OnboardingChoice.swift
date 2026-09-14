//
//  OnboardingChoice.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

/// A metric offered on the "what do you want to keep an eye on?" step.
/// The order matches the design's two-column grid.
enum TrackableMetric: String, CaseIterable, Identifiable, Codable {
    case steps, sleep, heartRate, workouts, food, weight, bloodPressure, howYouFeel

    var id: String { rawValue }

    var label: String {
        switch self {
        case .steps: "Steps"
        case .sleep: "Sleep"
        case .heartRate: "Heart rate"
        case .workouts: "Workouts"
        case .food: "Food"
        case .weight: "Weight"
        case .bloodPressure: "Blood pressure"
        case .howYouFeel: "How you feel"
        }
    }

    /// The metrics selected by default, matching the design's initial state.
    static let defaultSelection: Set<TrackableMetric> = [.steps, .sleep, .heartRate]
}

/// What the user is working towards. Sets goal firmness and how hard the app nudges.
enum TrainingAim: String, CaseIterable, Identifiable, Codable {
    case steadyHabit, trainForSomething, comeBackFromInjury, keepRecords

    var id: String { rawValue }

    var label: String {
        switch self {
        case .steadyHabit: "Build a steady habit"
        case .trainForSomething: "Train for something"
        case .comeBackFromInjury: "Come back from injury"
        case .keepRecords: "Just keep records"
        }
    }

    var sublabel: String {
        switch self {
        case .steadyHabit: "Gentle targets, and credit for showing up at all"
        case .trainForSomething: "Harder targets, load and recovery watched closely"
        case .comeBackFromInjury: "Slow ramp, and a warning when you push too soon"
        case .keepRecords: "No targets or nudges — only your numbers, kept tidy"
        }
    }
}
