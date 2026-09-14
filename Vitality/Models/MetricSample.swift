//
//  MetricSample.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//
//  NOTE: The values in this file are SAMPLE DATA carried over from the design.
//  Vitality has no health data source yet — wiring HealthKit would replace
//  `MetricSample.week` and the copy in `MetricDetail` with real readings.
//  Everything else in the app (habits, focus sessions) uses real stored data.
//

import Foundation

/// A health metric the app displays but does not yet measure.
enum MetricSample: String, CaseIterable, Identifiable {
    case steps, sleep, restingHeart, food, workouts, weight
    case bloodPressure, bloodOxygen, mood, cycle

    var id: String { rawValue }

    // MARK: - Weekly Series

    /// Seven days of readings, Monday to Sunday. Today is the last element.
    var week: [Double] {
        switch self {
        case .steps: [6200, 9100, 7400, 10300, 8600, 4900, 8420]
        case .restingHeart: [64, 63, 62, 61, 64, 66, 62]
        case .sleep: [6.5, 7.8, 7.1, 8.2, 7.4, 5.9, 7.2]
        case .food: [1980, 2100, 1870, 2260, 1990, 1740, 1840]
        case .workouts: [0, 1, 0, 1, 0, 0, 1]
        case .weight: [71.9, 71.8, 71.7, 71.6, 71.5, 71.5, 71.4]
        case .bloodPressure: [120, 122, 118, 116, 119, 121, 118]
        case .bloodOxygen: [97, 98, 98, 97, 99, 98, 98]
        case .mood: [3, 4, 4, 5, 4, 3, 4]
        case .cycle: [11, 12, 13, 14, 15, 16, 17]
        }
    }

    /// Metrics whose interesting range sits well above zero are plotted against
    /// a floor of 92% of their minimum, so day-to-day movement stays visible.
    private var usesFloor: Bool {
        switch self {
        case .restingHeart, .weight, .bloodPressure, .bloodOxygen: true
        default: false
        }
    }

    private static let dayInitials = ["M", "T", "W", "T", "F", "S", "S"]

    /// Builds the plotted columns, scaling to a 5% headroom above the week's peak.
    /// - Parameter todayOverride: replaces the final reading, so a logged walk
    ///   moves today's bar immediately.
    func chartBars(todayOverride: Double? = nil) -> [ChartBar] {
        var values = week
        if let todayOverride, self == .steps, !values.isEmpty {
            values[values.count - 1] = todayOverride
        }
        guard let peak = values.max(), let trough = values.min() else { return [] }

        let top = peak * 1.05
        let floor = usesFloor ? trough * 0.92 : 0
        let span = top - floor

        return values.enumerated().map { index, value in
            // A 6% minimum keeps a zero reading visible as a stub.
            let fraction = span > 0 ? max(0.06, (value - floor) / span) : 0.06
            return ChartBar(
                day: Self.dayInitials[index % Self.dayInitials.count],
                caption: caption(for: value),
                fraction: fraction,
                isToday: index == values.count - 1
            )
        }
    }

    /// The per-metric formatting used for the caption above each column.
    private func caption(for value: Double) -> String {
        switch self {
        case .steps: String(format: "%.1f", value / 1000)
        case .sleep: String(format: "%.1f", value)
        case .mood: ["", "Low", "Low", "OK", "Good", "Great"][min(Int(value), 5)]
        case .workouts: value > 0 ? "Yes" : "–"
        default: String(Int(value))
        }
    }
}

/// The copy and figures shown on a metric's detail screen.
struct MetricDetail {
    let kicker: String
    let label: String
    let value: String
    let unit: String
    let delta: String
    /// The "In plain words" explanation — the design's core idea, that a
    /// number is only useful once someone tells you what it means.
    let plain: String
    let callToAction: String
    let stats: [(key: String, value: String)]
}

extension MetricSample {
    var label: String {
        switch self {
        case .steps: "Steps"
        case .sleep: "Sleep"
        case .restingHeart: "Resting heart rate"
        case .food: "Food"
        case .workouts: "Workouts"
        case .weight: "Weight"
        case .bloodPressure: "Blood pressure"
        case .bloodOxygen: "Blood oxygen"
        case .mood: "How you feel"
        case .cycle: "Cycle"
        }
    }

    /// Detail copy for the metric, in the design's plain-language voice.
    /// - Parameters:
    ///   - steps: today's live step count, so the steps screen matches the tile.
    ///   - metric: whether weights read in kilograms or pounds.
    func detail(steps: Int, units: UnitSystem) -> MetricDetail {
        let kilograms = units == .kilograms

        switch self {
        case .steps:
            return MetricDetail(
                kicker: "Movement",
                label: label,
                value: steps.formatted(.number),
                unit: "steps today",
                delta: "+320 more than your usual Tuesday",
                plain: """
                    You walk most on Thursdays. Today you are 1,580 short of your \
                    goal — that is about a 20-minute walk, and an easy one to pick \
                    up after dinner.
                    """,
                callToAction: "Log a walk",
                stats: [
                    ("7-day average", "7,846"),
                    ("Best day", "Thu · 10,300"),
                    ("Goal met", "4 of 7 days")
                ]
            )

        case .sleep:
            return MetricDetail(
                kicker: "Recovery",
                label: label,
                value: "7h 10m",
                unit: "last night",
                delta: "50 minutes more than your average",
                plain: """
                    Your best nights start before 11pm. Six of the last seven were \
                    over seven hours, which is why your readiness is high today.
                    """,
                callToAction: "Log last night",
                stats: [
                    ("7-day average", "7h 09m"),
                    ("Longest", "Thu · 8h 12m"),
                    ("Bedtime range", "22:40 – 23:55")
                ]
            )

        case .restingHeart:
            return MetricDetail(
                kicker: "Heart",
                label: label,
                value: "62",
                unit: "bpm",
                delta: "Down 2 bpm over the month — a good sign",
                plain: """
                    Resting heart rate drifts down as fitness builds. Anything from \
                    55 to 70 is normal for you; a jump of 8 or more for a few days \
                    usually means you are tired or unwell.
                    """,
                callToAction: "Measure now",
                stats: [
                    ("7-day average", "63 bpm"),
                    ("Lowest", "Thu · 61 bpm"),
                    ("Month change", "−2 bpm")
                ]
            )

        case .food:
            return MetricDetail(
                kicker: "Nutrition",
                label: label,
                value: "1,840",
                unit: "kcal eaten",
                delta: "About 260 under your usual day",
                plain: """
                    You have eaten a little less than usual and moved a little more. \
                    If you are training tomorrow, a proper dinner is the right call.
                    """,
                callToAction: "Log a meal",
                stats: [
                    ("7-day average", "1,969 kcal"),
                    ("Protein today", "96 g"),
                    ("Water today", "2 of 6 glasses")
                ]
            )

        case .workouts:
            return MetricDetail(
                kicker: "Training",
                label: label,
                value: "3",
                unit: "this week",
                delta: "One more hits your weekly goal",
                plain: """
                    Three sessions so far: two easy runs and one strength. A fourth \
                    easy session — not a hard one — is what keeps the streak safe.
                    """,
                callToAction: "Start a workout",
                stats: [
                    ("This week", "3 sessions · 2h 10m"),
                    ("Last week", "2 sessions · 1h 25m"),
                    ("Longest", "Sun · 52m")
                ]
            )

        case .weight:
            return MetricDetail(
                kicker: "Body",
                label: label,
                value: kilograms ? "71.4" : "157.4",
                unit: kilograms ? "kg" : "lb",
                delta: "Down 0.5 over two weeks — steady",
                plain: """
                    Day-to-day changes are mostly water. The two-week direction is \
                    what matters, and yours is gently down.
                    """,
                callToAction: "Log a weigh-in",
                stats: [
                    ("7-day average", kilograms ? "71.6 kg" : "157.8 lb"),
                    ("Two-week change", kilograms ? "−0.5 kg" : "−1.1 lb"),
                    ("Last logged", "Today · 07:20")
                ]
            )

        case .bloodPressure:
            return MetricDetail(
                kicker: "Heart",
                label: label,
                value: "118/76",
                unit: "mmHg",
                delta: "In the normal range",
                plain: """
                    Both numbers sit in the normal range. Take readings sitting, \
                    after five quiet minutes, on the same arm each time.
                    """,
                callToAction: "Take a reading",
                stats: [
                    ("7-day average", "119/77"),
                    ("Highest", "Tue · 122/80"),
                    ("Readings", "7 of 7 days")
                ]
            )

        case .bloodOxygen:
            return MetricDetail(
                kicker: "Breathing",
                label: label,
                value: "98",
                unit: "%",
                delta: "Normal, and steady all week",
                plain: """
                    Anything from 95 to 100 percent is normal at rest. Single low \
                    readings are usually the sensor, not you.
                    """,
                callToAction: "Measure now",
                stats: [
                    ("7-day average", "98%"),
                    ("Lowest", "Mon · 97%"),
                    ("Readings", "12 this week")
                ]
            )

        case .mood:
            return MetricDetail(
                kicker: "Mood",
                label: label,
                value: "Good",
                unit: "today",
                delta: "Four good days out of seven",
                plain: """
                    Your better days follow your longer nights. That pattern has \
                    held for three weeks now.
                    """,
                callToAction: "Log how you feel",
                stats: [
                    ("Good or great", "4 of 7 days"),
                    ("Hardest day", "Saturday"),
                    ("Streak", "2 days")
                ]
            )

        case .cycle:
            return MetricDetail(
                kicker: "Cycle",
                label: label,
                value: "Day 17",
                unit: "of about 29",
                delta: "Next period expected 24 Sep",
                plain: """
                    You are in the second half of your cycle. Energy often dips in \
                    the last few days — planning easier sessions then tends to work \
                    well.
                    """,
                callToAction: "Log a symptom",
                stats: [
                    ("Average cycle", "29 days"),
                    ("Last period", "27 Aug · 5 days"),
                    ("Logged cycles", "14")
                ]
            )
        }
    }
}

/// The unit system used for weights.
enum UnitSystem: String, Codable, CaseIterable, Identifiable {
    case kilograms, pounds

    var id: String { rawValue }

    var label: String {
        switch self {
        case .kilograms: "Kilograms"
        case .pounds: "Pounds"
        }
    }
}
