//
//  LiveActivityService.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

/// Starts, updates, and ends the Dynamic Island / Lock Screen activity for a focus session.
///
/// Every call is a no-op when Live Activities are unavailable (Simulator without
/// support, disabled in Settings, or a platform without ActivityKit), so the timer
/// itself keeps working regardless.
@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()

    private init() {}

    #if canImport(ActivityKit)
    private var activity: Activity<FocusActivityAttributes>?

    var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(session: FocusSession, completedToday: Int, dailyGoal: Int) {
        guard isSupported, activity == nil else { return }

        let attributes = FocusActivityAttributes(
            habitTitle: session.habitTitle,
            categoryRawValue: session.category.rawValue,
            symbolName: session.category.symbolName
        )

        let state = FocusActivityAttributes.ContentState(
            startedAt: session.startedAt,
            endsAt: session.endsAt,
            completedToday: completedToday,
            dailyGoal: dailyGoal,
            isPaused: false
        )

        activity = try? Activity.request(
            attributes: attributes,
            content: .init(state: state, staleDate: session.endsAt),
            pushType: nil
        )
    }

    func update(session: FocusSession, completedToday: Int, dailyGoal: Int) async {
        guard let activity else { return }

        let state = FocusActivityAttributes.ContentState(
            startedAt: session.startedAt,
            endsAt: session.endsAt,
            completedToday: completedToday,
            dailyGoal: dailyGoal,
            isPaused: false
        )

        await activity.update(.init(state: state, staleDate: session.endsAt))
    }

    func end() async {
        guard let activity else { return }
        await activity.end(nil, dismissalPolicy: .immediate)
        self.activity = nil
    }
    #else
    var isSupported: Bool { false }
    func start(session: FocusSession, completedToday: Int, dailyGoal: Int) {}
    func update(session: FocusSession, completedToday: Int, dailyGoal: Int) async {}
    func end() async {}
    #endif
}
