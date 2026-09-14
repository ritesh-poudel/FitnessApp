//
//  GoalsView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The Goals tab: progress toward each daily goal, plus reminder switches.
struct GoalsView: View {
    @Bindable var model: BaselineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenTitle(title: "Goals", standfirst: "Small and steady beats big and rare.")

            goals

            SectionKicker(title: "Reminders")

            reminders

            PrimaryButton(title: "Add a goal") {
                model.flash("Pick a goal to add")
            }
            .padding(Theme.Spacing.gutter)
        }
    }

    // MARK: - Goals

    private var goals: some View {
        VStack(spacing: 0) {
            goalRow(
                title: "Move every day",
                progress: model.moveProgress,
                note: "10,000 steps · 5 of 7 days",
                action: "Log a walk"
            ) {
                model.isSheetPresented = true
            }

            goalRow(
                title: "Sleep seven hours",
                progress: model.sleepProgress,
                note: "6 of 7 nights over 7h",
                action: "Adjust"
            ) {
                model.flash("Goal editing comes next")
            }

            goalRow(
                title: "Six glasses of water",
                progress: model.waterProgress,
                note: "\(model.water) of \(BaselineViewModel.waterGoal) today",
                action: "Add a glass"
            ) {
                model.logWater()
            }
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    private func goalRow(
        title: String,
        progress: Double,
        note: String,
        action: String,
        perform: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Theme.text)

                Spacer(minLength: Theme.Spacing.x2)

                Text(progress, format: .percent.precision(.fractionLength(0)))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
                    .tabularNumbers()
                    .contentTransition(.numericText())
            }

            ProgressBarView(value: progress)
                .padding(.top, 10)

            HStack(spacing: Theme.Spacing.x3) {
                Text(note)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)

                Spacer(minLength: Theme.Spacing.x2)

                // A ghost action: accent type, no field, so the row keeps
                // its single emphasis on the bar.
                Button(action: perform) {
                    Text(action)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, Theme.Spacing.x1)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 9)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.vertical, 15)
        .overlay(alignment: .bottom) { RuleView() }
        .animation(Theme.Motion.progress, value: progress)
    }

    // MARK: - Reminders

    private var reminders: some View {
        VStack(spacing: 0) {
            ToggleRow(
                label: "Morning nudge",
                sublabel: "A gentle 8:30am hello",
                isOn: reminderBinding(\.morningReminder)
            )
            RuleView()

            ToggleRow(
                label: "Water check-ins",
                sublabel: "Three times during the day",
                isOn: reminderBinding(\.waterReminder)
            )
            RuleView()

            ToggleRow(
                label: "Wind-down",
                sublabel: "30 minutes before bedtime",
                isOn: reminderBinding(\.windDownReminder)
            )
            RuleView()
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    /// Wraps a reminder flag so flipping it also raises the confirmation toast.
    private func reminderBinding(
        _ keyPath: ReferenceWritableKeyPath<BaselineViewModel, Bool>
    ) -> Binding<Bool> {
        Binding(
            get: { model[keyPath: keyPath] },
            set: { newValue in
                model[keyPath: keyPath] = newValue
                model.flash(newValue ? "Reminder on" : "Reminder off")
            }
        )
    }
}

#Preview {
    ScrollView {
        GoalsView(model: BaselineViewModel())
    }
    .background(Theme.background)
}
