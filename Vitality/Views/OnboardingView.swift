//
//  OnboardingView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Five steps that set the app up and teach its reading habits at the same time.
///
/// Motion is the Modernist grid assembling itself: rules wipe out from the left,
/// lines rise and stagger in, the progress bar advances on a spring curve, and
/// steps slide in the direction of travel. The one red field moves with the step,
/// so each screen still has exactly one.
struct OnboardingView: View {
    @State private var model = OnboardingViewModel()
    /// Called once onboarding has written its setup.
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                progressBar

                steps

                footer
            }

            if let toast = model.toast {
                OnboardingToast(message: toast)
                    .zIndex(90)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.x3) {
            Text("BASELINE")
                .font(.system(size: 15, weight: .heavy))
                .kerning(15 * 0.16)
                .foregroundStyle(Theme.text)

            Spacer(minLength: Theme.Spacing.x2)

            Text(model.stepCount)
                .kicker(tracking: 0.1)
                .tabularNumbers()
                .foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, 10)
    }

    private var progressBar: some View {
        ProgressBarView(value: model.progress, height: 6)
            .padding(.horizontal, Theme.Spacing.gutter)
    }

    // MARK: - Steps

    private var steps: some View {
        ScrollView {
            Group {
                switch model.step {
                case .welcome: welcome
                case .metrics: metrics
                case .aim: aim
                case .comfort: comfort
                case .summary: summary
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            // Steps slide in from the direction of travel.
            .transition(
                .asymmetric(
                    insertion: .move(edge: model.direction < 0 ? .leading : .trailing)
                        .combined(with: .opacity),
                    removal: .opacity
                )
            )
            .id(model.step)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Step One: Welcome

    private var welcome: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // The rule that wipes out from the left as the screen assembles.
                Rectangle()
                    .fill(Theme.text)
                    .frame(height: Theme.rule)

                Text("Welcome")
                    .kicker(tracking: 0.14)
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 14)

                Text("One place for\nyour body and\nyour day.")
                    .font(.system(size: 41, weight: .heavy))
                    .kerning(41 * -0.035)
                    .lineSpacing(0)
                    .foregroundStyle(Theme.text)
                    .padding(.top, Theme.Spacing.x2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Baseline reads your health data in plain language, and plans your day around what it finds. Setup takes about a minute.")
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundStyle(Theme.muted)
                    .frame(maxWidth: 300, alignment: .leading)
                    .padding(.top, 14)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, 26)

            // The single accent field on this step.
            VStack(alignment: .leading, spacing: 6) {
                Text("No noise, no streak-shaming")
                    .kicker(tracking: 0.14)
                    .foregroundStyle(.white)

                Text("Numbers big enough to read at a glance, words you already use.")
                    .font(.system(size: 25, weight: .heavy))
                    .kerning(25 * -0.02)
                    .lineSpacing(2)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.gutter)
            .background(Theme.accent)
            .padding(.top, 22)

            // A sample chart, bars growing from the baseline.
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(Array(model.welcomeBars.enumerated()), id: \.offset) { _, bar in
                    Rectangle()
                        .fill(bar.isAccent ? Theme.accent : Theme.Neutral.n300)
                        .frame(maxWidth: .infinity)
                        .frame(height: max(74 * bar.height, 2))
                }
            }
            .frame(height: 74, alignment: .bottom)
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, 22)
            .accessibilityHidden(true)
        }
        .padding(.bottom, Theme.Spacing.gutter)
    }

    // MARK: - Step Two: Metrics

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepHeading(
                kicker: "Step one",
                title: "What do you want to keep an eye on?",
                standfirst: "Pick as many as you like. These go on your Today screen first."
            )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Theme.rule),
                    GridItem(.flexible(), spacing: Theme.rule)
                ],
                spacing: Theme.rule
            ) {
                ForEach(TrackableMetric.allCases) { metric in
                    let isPicked = model.selectedMetrics.contains(metric)

                    Button {
                        withAnimation(Theme.Motion.state) {
                            model.toggle(metric)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Rectangle()
                                .fill(isPicked ? .white : .clear)
                                .frame(width: 18, height: 18)
                                .overlay {
                                    Rectangle()
                                        .strokeBorder(
                                            isPicked ? .white : Theme.text,
                                            lineWidth: Theme.rule
                                        )
                                }

                            Text(metric.label)
                                .font(.system(size: 13.5, weight: .heavy))
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(isPicked ? .white : Theme.text)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, minHeight: 76, alignment: .topLeading)
                        .background(isPicked ? Theme.accent : Theme.background)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(metric.label)
                    .accessibilityAddTraits(isPicked ? [.isButton, .isSelected] : .isButton)
                }
            }
            .background(Theme.divider)
            .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
            .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }

            Text(model.pickNote)
                .font(.system(size: 12))
                .tabularNumbers()
                .foregroundStyle(Theme.muted)
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.top, 14)
        }
        .padding(.bottom, Theme.Spacing.gutter)
    }

    // MARK: - Step Three: Aim

    private var aim: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepHeading(
                kicker: "Step two",
                title: "What are you working towards?",
                standfirst: "This sets your goals and how firmly we nudge you. You can change it later."
            )

            VStack(spacing: 0) {
                ForEach(TrainingAim.allCases) { option in
                    let isPicked = model.aim == option

                    Button {
                        withAnimation(Theme.Motion.state) {
                            model.aim = option
                        }
                    } label: {
                        HStack(spacing: 14) {
                            // The leading rule that marks the chosen row.
                            Rectangle()
                                .fill(isPicked ? .white : Theme.Neutral.n300)
                                .frame(width: 2)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(option.label)
                                    .font(.system(size: 17, weight: .heavy))
                                    .kerning(17 * -0.01)
                                    .multilineTextAlignment(.leading)

                                Text(option.sublabel)
                                    .font(.system(size: 12))
                                    .lineSpacing(2)
                                    .foregroundStyle(
                                        isPicked ? .white.opacity(0.9) : Theme.muted
                                    )
                                    .frame(maxWidth: 250, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer(minLength: Theme.Spacing.x2)

                            if isPicked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .heavy))
                            }
                        }
                        .foregroundStyle(isPicked ? .white : Theme.text)
                        .padding(.horizontal, Theme.Spacing.gutter)
                        .padding(.vertical, 12)
                        .frame(minHeight: 84)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isPicked ? Theme.accent : Theme.background)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.label)
                    .accessibilityHint(option.sublabel)
                    .accessibilityAddTraits(isPicked ? [.isButton, .isSelected] : .isButton)

                    RuleView()
                }
            }
            .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
        }
        .padding(.bottom, Theme.Spacing.gutter)
    }

    // MARK: - Step Four: Comfort

    private var comfort: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepHeading(
                kicker: "Step three",
                title: "Set it so it's easy to read.",
                standfirst: "Change anything here and the sample below changes with it."
            )

            VStack(spacing: 0) {
                ToggleRow(
                    label: "Bigger text",
                    sublabel: "Everything scales up together",
                    isOn: $model.biggerText
                )
                RuleView()

                ToggleRow(
                    label: "Stronger labels",
                    sublabel: "Darker small type against the ground",
                    isOn: $model.strongerLabels
                )
                RuleView()
            }
            .overlay(alignment: .top) { RuleView(weight: Theme.rule) }

            // A live sample that responds to both switches.
            VStack(alignment: .leading, spacing: 0) {
                Text("Sample")
                    .kicker()
                    .foregroundStyle(Theme.muted)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Steps today")
                        .kicker(size: 10.5, tracking: 0.11)
                        .foregroundStyle(model.strongerLabels ? Theme.text : Theme.muted)

                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text("8,420")
                            .font(.system(size: 44, weight: .heavy))
                            .kerning(44 * -0.035)
                            .tabularNumbers()
                            .foregroundStyle(Theme.text)

                        Text("steps")
                            .font(.system(size: 13))
                            .foregroundStyle(model.strongerLabels ? Theme.text : Theme.muted)
                    }
                    .padding(.top, 3)

                    Text("About a 20-minute walk from your goal.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Theme.Accent.a700)
                        .padding(.top, 5)
                }
                .padding(.top, 12)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Theme.text)
                        .frame(height: Theme.rule)
                }
                .padding(.top, Theme.Spacing.x2)
                .scaleEffect(model.biggerText ? 1.16 : 1, anchor: .topLeading)
                .animation(Theme.Motion.state, value: model.biggerText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.gutter)
        }
        .padding(.bottom, Theme.Spacing.gutter)
    }

    // MARK: - Step Five: Summary

    private var summary: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("You're set up")
                    .kicker(tracking: 0.14)
                    .foregroundStyle(Theme.muted)

                Text("Here's your first reading.")
                    .font(.system(size: 34, weight: .heavy))
                    .kerning(34 * -0.03)
                    .foregroundStyle(Theme.text)
                    .padding(.top, 7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, 26)

            // The readiness field, counting up on arrival.
            VStack(alignment: .leading, spacing: 0) {
                Text("Today's readiness")
                    .kicker(tracking: 0.14)
                    .foregroundStyle(.white)

                HStack(alignment: .bottom, spacing: Theme.Spacing.x3) {
                    Text("\(model.score)")
                        .font(.system(size: 76, weight: .heavy))
                        .kerning(76 * -0.04)
                        .tabularNumbers()
                        .foregroundStyle(.white)

                    Text("out of 100, from your last night of sleep and your resting heart rate.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 170, alignment: .leading)
                        .padding(.bottom, 7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.gutter)
            .background(Theme.accent)
            .padding(.top, Theme.Spacing.gutter)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Today's readiness, \(model.score) out of 100")

            VStack(spacing: 0) {
                ForEach(model.summaryLines, id: \.key) { line in
                    HStack(spacing: Theme.Spacing.x3) {
                        Text(line.key)
                            .kicker(size: 10.5, tracking: 0.11)
                            .foregroundStyle(Theme.muted)
                            .frame(width: 106, alignment: .leading)

                        Spacer(minLength: Theme.Spacing.x2)

                        Text(line.value)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(Theme.text)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.vertical, 10)
                    .frame(minHeight: 60)
                    .overlay(alignment: .bottom) { RuleView() }
                    .accessibilityElement(children: .combine)
                }
            }
            .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }

            Text("Nothing here is locked in. Every choice lives under You, and you can add a metric whenever you want one.")
                .font(.system(size: 13))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.top, Theme.Spacing.x4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, Theme.Spacing.gutter)
    }

    // MARK: - Shared

    private func stepHeading(
        kicker: String,
        title: String,
        standfirst: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(kicker)
                .kicker(tracking: 0.14)
                .foregroundStyle(Theme.muted)

            Text(title)
                .font(.system(size: 31, weight: .heavy))
                .kerning(31 * -0.03)
                .lineSpacing(1)
                .foregroundStyle(Theme.text)
                .padding(.top, 7)
                .fixedSize(horizontal: false, vertical: true)

            Text(standfirst)
                .font(Theme.TypeScale.body)
                .foregroundStyle(Theme.muted)
                .padding(.top, Theme.Spacing.x2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.top, 26)
        .padding(.bottom, Theme.Spacing.x4)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 9) {
            PrimaryButton(title: model.step.callToAction, height: 54) {
                Task {
                    if await model.advance() {
                        onComplete()
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    model.goBack()
                } label: {
                    Text(model.backLabel)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, Theme.Spacing.x1)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer(minLength: Theme.Spacing.x2)

                Text(model.footnote)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.top, 14)
        .padding(.bottom, Theme.Spacing.x2)
        .background(Theme.background)
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }
}

/// The onboarding toast, which sits above the footer rather than the tab bar.
struct OnboardingToast: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Text(message)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Theme.background)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
            .background(Theme.text)
            .padding(.horizontal, 14)
            .padding(.bottom, 112)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
