//
//  PlanView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The Plan tab: the focus timer, today's checklist, the day's blocks and streaks.
/// This is the productivity side, and the one tab backed by real stored habits.
struct PlanView: View {
    @Bindable var model: BaselineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenTitle(title: "Plan", standfirst: model.planSummary)

            focusSession

            checklist

            SectionKicker(title: "Your day")

            blocks

            SectionKicker(title: "Streaks")

            streaks

            planTomorrow
        }
    }

    // MARK: - Focus

    /// This screen's single accent field: the running clock and its controls.
    private var focusSession: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Focus session")
                .kicker(tracking: 0.14)
                .foregroundStyle(.white)

            Text(model.clock)
                .font(Theme.TypeScale.clock)
                .kerning(70 * -0.04)
                .tabularNumbers()
                .contentTransition(.numericText())
                .foregroundStyle(.white)
                .padding(.top, 2)
                .accessibilityLabel("\(model.secondsRemaining / 60) minutes remaining")

            Text(model.focusNote)
                .font(.system(size: 12.5))
                .foregroundStyle(.white)
                .padding(.top, 4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Theme.rule) {
                Button {
                    Task { await model.toggleFocus() }
                } label: {
                    Text(model.focusLabel)
                        .font(.system(size: 13, weight: .heavy))
                        .kerning(13 * 0.08)
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                        .background(.white)
                }
                .buttonStyle(.plain)

                Button {
                    Task { await model.resetFocus() }
                } label: {
                    Text("Reset")
                        .font(.system(size: 13, weight: .heavy))
                        .kerning(13 * 0.08)
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .frame(width: 108, height: 48, alignment: .leading)
                        .overlay {
                            Rectangle()
                                .strokeBorder(.white, lineWidth: Theme.rule)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 14)

            // Completed blocks, drawn as filled squares.
            HStack(spacing: 5) {
                ForEach(0..<BaselineViewModel.pomodoroTarget, id: \.self) { index in
                    Rectangle()
                        .fill(index < model.completedPomodoros ? .white : .clear)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Rectangle().strokeBorder(.white, lineWidth: Theme.rule)
                        }
                }

                Text(model.pomodoroNote)
                    .kicker(tracking: 0.1)
                    .foregroundStyle(.white)
                    .padding(.leading, 6)
            }
            .padding(.top, 14)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.pomodoroNote)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.vertical, Theme.Spacing.x4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent)
    }

    // MARK: - Checklist

    private var checklist: some View {
        VStack(spacing: 0) {
            SectionKicker(title: "Today's checklist", trailing: "\(model.completedTaskCount) of \(model.tasks.count)")

            ProgressBarView(value: model.taskProgress)
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.x3)

            VStack(spacing: 0) {
                ForEach(model.tasks) { habit in
                    Button {
                        Task { await model.toggle(habit) }
                    } label: {
                        HStack(spacing: 13) {
                            // A square checkbox, filled in accent when ticked.
                            Rectangle()
                                .fill(habit.isComplete ? Theme.accent : .clear)
                                .frame(width: 28, height: 28)
                                .overlay {
                                    Rectangle().strokeBorder(Theme.text, lineWidth: Theme.rule)
                                }
                                .overlay {
                                    if habit.isComplete {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .heavy))
                                            .foregroundStyle(.white)
                                    }
                                }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(habit.title)
                                    .font(.system(size: 14.5))
                                    .strikethrough(habit.isComplete)
                                    .foregroundStyle(habit.isComplete ? Theme.muted : Theme.text)
                                    .multilineTextAlignment(.leading)

                                if !habit.planSublabel.isEmpty {
                                    Text(habit.planSublabel)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.muted)
                                        .multilineTextAlignment(.leading)
                                }
                            }

                            Spacer(minLength: Theme.Spacing.x2)

                            Text(habit.planTag)
                                .kicker(size: 10, tracking: 0.1)
                                .foregroundStyle(Theme.muted)
                        }
                        .padding(.horizontal, Theme.Spacing.gutter)
                        .frame(minHeight: 62)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(RowButtonStyle())
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(habit.title)
                    .accessibilityValue(habit.isComplete ? "Done" : "Not done")
                    .accessibilityAddTraits(.isButton)

                    RuleView()
                }
            }
            .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
            .animation(Theme.Motion.state, value: model.completedTaskCount)
        }
    }

    // MARK: - Blocks

    private var blocks: some View {
        VStack(spacing: 0) {
            ForEach(TimeBlock.sampleDay) { block in
                HStack(spacing: 14) {
                    Text(block.time)
                        .font(.system(size: 13, weight: .heavy))
                        .tabularNumbers()
                        .foregroundStyle(block.state.timeInk)
                        .frame(width: 52, alignment: .leading)

                    // The vertical rule that ties a block to its time.
                    Rectangle()
                        .fill(block.state.rule)
                        .frame(width: 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(block.label)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.leading)

                        Text(block.sublabel)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Theme.muted)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: Theme.Spacing.x2)

                    if !block.state.rawValue.isEmpty {
                        Text(block.state.rawValue)
                            .kicker(size: 10, tracking: 0.1)
                            .foregroundStyle(block.state.stateInk)
                    }
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.vertical, 10)
                .frame(minHeight: 64)
                .background(block.state.background)
                .overlay(alignment: .bottom) { RuleView() }
                .accessibilityElement(children: .combine)
            }
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Streaks

    private var streaks: some View {
        HStack(spacing: Theme.rule) {
            ForEach(model.streaks, id: \.label) { streak in
                VStack(alignment: .leading, spacing: 2) {
                    Text(streak.value)
                        .font(Theme.TypeScale.streak)
                        .kerning(30 * -0.03)
                        .tabularNumbers()
                        .foregroundStyle(Theme.text)

                    Text(streak.label)
                        .kicker(tracking: 0.1)
                        .foregroundStyle(Theme.muted)
                }
                .padding(.horizontal, Theme.Spacing.x3)
                .padding(.top, Theme.Spacing.x3)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.background)
                .accessibilityElement(children: .combine)
            }
        }
        .background(Theme.divider)
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
        .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Plan Tomorrow

    private var planTomorrow: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrimaryButton(title: "Plan tomorrow") {
                model.flash("Tomorrow drafted from your usual day")
            }

            Text("We'll suggest blocks that fit around your sleep and training.")
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.gutter)
    }
}

#Preview {
    ScrollView {
        PlanView(model: BaselineViewModel())
    }
    .background(Theme.background)
}
