//
//  HabitCardView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// One habit's daily progress, its log controls, and its focus timer.
struct HabitCardView: View {
    let habit: Habit
    /// The running session, when it belongs to this habit.
    var session: FocusSession?
    let onLog: () -> Void
    let onUndo: () -> Void
    let onStartTimer: () -> Void
    let onStopTimer: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isTiming: Bool { session != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            title

            counts

            ProgressBarView(value: habit.progress, color: habit.category.tint)

            controls
        }
        .cardStyle(accent: isTiming ? habit.category.tint : nil)
    }

    // MARK: - Title

    private var title: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
            Text(habit.title)
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(Theme.ink(for: colorScheme))

            Spacer(minLength: Theme.Spacing.sm)

            if habit.isComplete {
                Text("Met")
                    .labelStyle()
                    .foregroundStyle(habit.category.tint)
                    .transition(.opacity)
            }
        }
        .animation(Theme.Motion.state, value: habit.isComplete)
    }

    // MARK: - Counts

    /// The big numeral pairing that carries the card, Swiss-style.
    private var counts: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
            Text("\(habit.completedToday)")
                .font(.system(size: 34, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(Theme.ink(for: colorScheme))

            Text("/ \(habit.dailyGoal)")
                .font(.system(size: 17, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(.secondary)

            Spacer()

            if let session {
                // A live countdown that keeps ticking without a timer in the view.
                Text(timerInterval: session.range, countsDown: true)
                    .font(.system(size: 17, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(habit.category.tint)
                    .accessibilityLabel("Focus time remaining")
            }
        }
        .animation(Theme.Motion.progress, value: habit.completedToday)
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: Theme.Spacing.sm) {
            timerButton

            Spacer()

            squareButton(
                systemImage: "minus",
                label: "Undo one completion of \(habit.title)",
                action: onUndo
            )
            .disabled(habit.completedToday == 0)

            squareButton(
                systemImage: "plus",
                label: "Log one completion of \(habit.title)",
                filled: true,
                action: onLog
            )
        }
    }

    private var timerButton: some View {
        Button(action: isTiming ? onStopTimer : onStartTimer) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: isTiming ? "stop.fill" : "play.fill")
                    .font(.system(size: 10, weight: .bold))

                Text(isTiming ? "Stop" : "Focus")
                    .labelStyle()
            }
            .foregroundStyle(habit.category.tint)
            .padding(.horizontal, Theme.Spacing.md)
            .frame(height: 36)
            .overlay {
                Rectangle()
                    .strokeBorder(habit.category.tint, lineWidth: Theme.hairline)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            isTiming ? "Stop focus timer for \(habit.title)" : "Start focus timer for \(habit.title)"
        )
    }

    private func squareButton(
        systemImage: String,
        label: String,
        filled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(filled ? Color.white : Theme.ink(for: colorScheme))
                .frame(width: 44, height: 36)
                .background(filled ? habit.category.tint : .clear)
                .overlay {
                    Rectangle()
                        .strokeBorder(
                            filled ? .clear : Theme.rule(for: colorScheme),
                            lineWidth: Theme.hairline
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    let habit = Habit(title: "Deep work session", category: .productivity, dailyGoal: 3, completedToday: 1)

    return VStack(spacing: Theme.Spacing.md) {
        HabitCardView(
            habit: Habit(title: "Drink water", category: .health, dailyGoal: 8, completedToday: 3),
            onLog: {}, onUndo: {}, onStartTimer: {}, onStopTimer: {}
        )

        HabitCardView(
            habit: habit,
            session: FocusSession(
                habitID: habit.id,
                habitTitle: habit.title,
                category: habit.category
            ),
            onLog: {}, onUndo: {}, onStartTimer: {}, onStopTimer: {}
        )
    }
    .padding()
    .background(Theme.canvas(for: .light))
}
