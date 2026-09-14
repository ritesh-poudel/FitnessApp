//
//  FocusActivityAttributes.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//
//  NOTE: This file must belong to BOTH the app target and the widget
//  extension target so the Live Activity payload type matches on each side.
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// Payload describing a running focus session on the Lock Screen and Dynamic Island.
struct FocusActivityAttributes: ActivityAttributes {
    /// Values that change while the activity is live.
    struct ContentState: Codable, Hashable {
        /// Start and end of the countdown, rendered with `Text(timerInterval:)`.
        var startedAt: Date
        var endsAt: Date
        /// Completions logged for this habit so far today.
        var completedToday: Int
        var dailyGoal: Int
        var isPaused: Bool

        var progress: Double {
            let total = endsAt.timeIntervalSince(startedAt)
            guard total > 0 else { return 1 }
            let done = Date().timeIntervalSince(startedAt)
            return min(max(done / total, 0), 1)
        }
    }

    // Static for the life of the activity.
    var habitTitle: String
    var categoryRawValue: String
    var symbolName: String

    var category: HabitCategory {
        HabitCategory(rawValue: categoryRawValue) ?? .productivity
    }
}
#endif
