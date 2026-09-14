//
//  BaselineView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The app's root. Holds the header, the five tabs, the pushed metric detail,
/// the quick-log sheet and the toast.
struct BaselineView: View {
    @State private var model = BaselineViewModel()

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                BaselineHeader()

                ScrollView {
                    // Bigger text scales the whole screen rather than restyling
                    // it, as the design specifies. `dynamicTypeSize` is used in
                    // preference to `scaleEffect`, which would scale the layout
                    // without giving the ScrollView the taller content size and
                    // would clip the top of the screen.
                    tabContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .environment(\.sizeCategory, model.largeType ? .accessibilityMedium : .large)
                .animation(Theme.Motion.state, value: model.largeType)

                BaselineTabBar(selection: $model.tab)
            }

            // The pushed detail covers the tab bar, as a native push would.
            if let metric = model.detail {
                MetricDetailView(model: model, metric: metric)
                    .transition(
                        model.reduceMotion
                            ? .opacity
                            : .move(edge: .trailing)
                    )
                    .zIndex(70)
            }

            if model.isSheetPresented {
                LogSheet(model: model)
                    .zIndex(80)
            }

            if let toast = model.toast {
                ToastView(message: toast)
                    .zIndex(90)
            }
        }
        .animation(model.reduceMotion ? nil : Theme.Motion.push, value: model.detail)
        .animation(Theme.Motion.state, value: model.isSheetPresented)
        .task {
            await model.load()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch model.tab {
        case .today: TodayView(model: model)
        case .trends: TrendsView(model: model)
        case .plan: PlanView(model: model)
        case .goals: GoalsView(model: model)
        case .profile: ProfileView(model: model)
        }
    }
}

// MARK: - Log Sheet

/// The bottom sheet offering one-tap logging.
struct LogSheet: View {
    @Bindable var model: BaselineViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.Neutral.n900.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    model.isSheetPresented = false
                }
                .accessibilityLabel("Close")
                .accessibilityAddTraits(.isButton)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Log something")
                        .font(Theme.TypeScale.sheetTitle)
                        .kerning(22 * -0.02)
                        .foregroundStyle(Theme.text)

                    Spacer()

                    Button {
                        model.isSheetPresented = false
                    } label: {
                        Text("Close")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, Theme.Spacing.x1)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                Text("One tap. You can edit it later.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 4)
                    .padding(.bottom, 14)

                VStack(spacing: Theme.rule) {
                    ForEach(model.sheetActions) { action in
                        Button(action: action.run) {
                            HStack(spacing: Theme.Spacing.x3) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(action.label)
                                        .font(.system(size: 15, weight: .heavy))
                                        .foregroundStyle(Theme.text)

                                    Text(action.sublabel)
                                        .font(.system(size: 11.5))
                                        .foregroundStyle(Theme.muted)
                                }

                                Spacer(minLength: Theme.Spacing.x2)

                                Image(systemName: "plus")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(Theme.accent)
                            }
                            .padding(.horizontal, Theme.Spacing.x4)
                            .frame(minHeight: 64)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.background)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(action.label)
                        .accessibilityHint(action.sublabel)
                    }
                }
                .background(Theme.divider)
                .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
                .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .padding(.top, Theme.Spacing.x4)
            .padding(.bottom, 42)
            .frame(maxWidth: .infinity)
            .background(Theme.background)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Theme.text)
                    .frame(height: Theme.rule)
            }
            .transition(model.reduceMotion ? .opacity : .move(edge: .bottom))
        }
    }
}

// MARK: - Toast

/// The confirmation that appears above the tab bar after a logged action.
struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 10) {
                Text(message)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Theme.background)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 13)
            .background(Theme.text)
            .padding(.horizontal, 14)
            .padding(.bottom, 96)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
    }
}

#Preview {
    BaselineView()
}
