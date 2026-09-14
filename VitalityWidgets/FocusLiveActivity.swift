//
//  FocusLiveActivity.swift
//  VitalityWidgets
//
//  Created by Aang phurba Sherpa on 9/14/26.
//
//  Belongs to the widget extension target. Renders the focus session on the
//  Lock Screen and in every Dynamic Island presentation.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct FocusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            lockScreen(context: context)
                .activityBackgroundTint(Color.black)
                .activitySystemActionForegroundColor(context.attributes.category.tint)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.symbolName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(context.attributes.category.tint)
                        .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: context.state.startedAt...context.state.endsAt, countsDown: true)
                        .font(.system(size: 22, weight: .bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .frame(width: 84)
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.habitTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(
                            timerInterval: context.state.startedAt...context.state.endsAt,
                            countsDown: true,
                            label: { EmptyView() },
                            currentValueLabel: { EmptyView() }
                        )
                        .tint(context.attributes.category.tint)

                        HStack {
                            Text("TODAY")
                                .font(.system(size: 10, weight: .bold))
                                .kerning(1.2)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text("\(context.state.completedToday) / \(context.state.dailyGoal)")
                                .font(.system(size: 10, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(context.attributes.category.tint)
                        }
                    }
                    .padding(.top, 2)
                }
            } compactLeading: {
                Image(systemName: context.attributes.symbolName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(context.attributes.category.tint)
            } compactTrailing: {
                Text(timerInterval: context.state.startedAt...context.state.endsAt, countsDown: true)
                    .font(.system(size: 13, weight: .semibold))
                    .monospacedDigit()
                    .frame(width: 44)
                    .foregroundStyle(context.attributes.category.tint)
            } minimal: {
                Image(systemName: context.attributes.symbolName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(context.attributes.category.tint)
            }
            .keylineTint(context.attributes.category.tint)
        }
    }

    // MARK: - Lock Screen

    /// Swiss layout: uppercase head, rule, oversized countdown.
    private func lockScreen(
        context: ActivityViewContext<FocusActivityAttributes>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Focus")
                    .font(.system(size: 11, weight: .bold))
                    .kerning(1.2)
                    .foregroundStyle(context.attributes.category.tint)

                Spacer()

                Text("\(context.state.completedToday) / \(context.state.dailyGoal)")
                    .font(.system(size: 11, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Rectangle()
                .fill(context.attributes.category.tint)
                .frame(height: 2)

            HStack(alignment: .firstTextBaseline) {
                Text(context.attributes.habitTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white)

                Spacer(minLength: 12)

                Text(timerInterval: context.state.startedAt...context.state.endsAt, countsDown: true)
                    .font(.system(size: 34, weight: .bold))
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)
                    .frame(width: 130)
                    .foregroundStyle(.white)
            }

            ProgressView(
                timerInterval: context.state.startedAt...context.state.endsAt,
                countsDown: true,
                label: { EmptyView() },
                currentValueLabel: { EmptyView() }
            )
            .tint(context.attributes.category.tint)
        }
        .padding(16)
    }
}
