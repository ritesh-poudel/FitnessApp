//
//  HabitCardView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Reusable row showing one habit's daily progress and its log controls.
struct HabitCardView: View {
    let habit: Habit
    let onLog: () -> Void
    let onUndo: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: habit.category.symbolName)
                    .foregroundStyle(habit.category.tint)

                Text(habit.title)
                    .font(.headline)

                Spacer()

                if habit.isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .accessibilityLabel("Goal met")
                }
            }

            ProgressView(value: habit.progress)
                .tint(habit.category.tint)

            HStack {
                Text("\(habit.completedToday) of \(habit.dailyGoal) today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: onUndo) {
                    Image(systemName: "minus")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.bordered)
                .disabled(habit.completedToday == 0)
                .accessibilityLabel("Undo one completion of \(habit.title)")

                Button(action: onLog) {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(habit.category.tint)
                .accessibilityLabel("Log one completion of \(habit.title)")
            }
        }
        .cardStyle()
    }
}

#Preview {
    VStack {
        HabitCardView(
            habit: Habit(title: "Drink water", category: .health, dailyGoal: 8, completedToday: 3),
            onLog: {},
            onUndo: {}
        )

        HabitCardView(
            habit: Habit(title: "Deep work session", category: .productivity, dailyGoal: 3, completedToday: 3),
            onLog: {},
            onUndo: {}
        )
    }
    .padding()
}
