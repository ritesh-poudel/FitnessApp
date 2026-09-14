//
//  DashboardView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                    summary

                    ForEach(HabitCategory.allCases) { category in
                        let habits = viewModel.habits(in: category)
                        if !habits.isEmpty {
                            section(for: category, habits: habits)
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.canvas(for: colorScheme))
            .navigationTitle("Today")
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Summary

    /// Masthead: an oversized percentage set against the date and goal count.
    private var summary: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Daily Progress")
                    .labelStyle()
                    .foregroundStyle(.secondary)

                Spacer()

                Text(Date.now, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .labelStyle(weight: .medium)
                    .foregroundStyle(.secondary)
            }

            RuleView(color: Theme.ink(for: colorScheme), weight: 2)

            Text(viewModel.dayProgress, format: .percent.precision(.fractionLength(0)))
                .font(.system(size: 72, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(Theme.ink(for: colorScheme))
                .animation(Theme.Motion.progress, value: viewModel.dayProgress)

            ProgressBarView(
                value: viewModel.dayProgress,
                color: Theme.ink(for: colorScheme),
                height: 8
            )

            Text("\(viewModel.completedCount) / \(viewModel.habits.count) goals met")
                .labelStyle(weight: .medium)
                .monospacedDigit()
                .contentTransition(.numericText())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sections

    private func section(for category: HabitCategory, habits: [Habit]) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                Text(category.displayName)
                    .labelStyle()
                    .foregroundStyle(category.tint)

                Spacer()

                Text("\(habits.filter(\.isComplete).count) / \(habits.count)")
                    .labelStyle(weight: .medium)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            RuleView(color: category.tint)

            ForEach(habits) { habit in
                HabitCardView(
                    habit: habit,
                    session: viewModel.isRunningSession(for: habit) ? viewModel.activeSession : nil,
                    onLog: { Task { await viewModel.logCompletion(for: habit) } },
                    onUndo: { Task { await viewModel.undoCompletion(for: habit) } },
                    onStartTimer: { Task { await viewModel.startSession(for: habit) } },
                    onStopTimer: { Task { await viewModel.cancelSession() } }
                )
            }
        }
    }
}

#Preview {
    DashboardView()
}
