//
//  FocusSession.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

/// A running focus timer attached to one habit. Completing it logs a completion.
struct FocusSession: Identifiable, Codable, Hashable {
    let id: UUID
    let habitID: UUID
    let habitTitle: String
    let category: HabitCategory
    let startedAt: Date
    /// Wall-clock length of the session.
    let duration: TimeInterval

    init(
        id: UUID = UUID(),
        habitID: UUID,
        habitTitle: String,
        category: HabitCategory,
        startedAt: Date = Date(),
        duration: TimeInterval = FocusSession.defaultDuration
    ) {
        self.id = id
        self.habitID = habitID
        self.habitTitle = habitTitle
        self.category = category
        self.startedAt = startedAt
        self.duration = duration
    }

    /// Default focus block, in seconds.
    static let defaultDuration: TimeInterval = 25 * 60

    var endsAt: Date {
        startedAt.addingTimeInterval(duration)
    }

    /// The range ActivityKit and `Text(timerInterval:)` use to render a live countdown.
    var range: ClosedRange<Date> {
        startedAt...endsAt
    }

    func remaining(at date: Date = Date()) -> TimeInterval {
        max(endsAt.timeIntervalSince(date), 0)
    }

    func progress(at date: Date = Date()) -> Double {
        guard duration > 0 else { return 1 }
        return min(max(date.timeIntervalSince(startedAt) / duration, 0), 1)
    }

    func isFinished(at date: Date = Date()) -> Bool {
        date >= endsAt
    }
}

extension TimeInterval {
    /// Formats a duration as `mm:ss` for static (non-live) display.
    var clockString: String {
        let total = Int(rounded())
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
