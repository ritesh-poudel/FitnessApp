//
//  TrendsView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The Trends tab: three numeral-led findings, the step chart, and a
/// week-on-week comparison table.
struct TrendsView: View {
    @Bindable var model: BaselineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenTitle(title: "Your week", standfirst: "6–12 September")

            weekLines

            SectionKicker(title: "Steps, by day")

            BarChartView(bars: MetricSample.steps.chartBars(todayOverride: Double(model.steps)))
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.bottom, Theme.Spacing.gutter)

            comparison

            BlockGridView(
                title: "Move goal, last four weeks",
                levels: BlockLevel.lastFourWeeks
            )
            .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
        }
    }

    // MARK: - Findings

    /// Each finding leads with the figure, set large, then explains it.
    private var weekLines: some View {
        VStack(spacing: 0) {
            ForEach(model.weekLines) { line in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text(line.numeral)
                        .font(Theme.TypeScale.weekNumeral)
                        .kerning(34 * -0.03)
                        .tabularNumbers()
                        .foregroundStyle(line.color)
                        .frame(minWidth: 86, alignment: .leading)

                    Text(line.text)
                        .font(Theme.TypeScale.body)
                        .foregroundStyle(Theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Theme.Spacing.gutter)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)

                RuleView()
            }
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Comparison

    private var comparison: some View {
        VStack(spacing: 0) {
            // Header row, set as a kicker over a 2px rule.
            HStack(spacing: Theme.Spacing.x2) {
                Text("Metric")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("This week")
                    .frame(width: 84, alignment: .leading)
                Text("Last week")
                    .frame(width: 84, alignment: .leading)
            }
            .kicker(size: 11, tracking: 0.08)
            .foregroundStyle(Theme.muted)
            .padding(.vertical, Theme.Spacing.x2)
            .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }

            ForEach(model.comparisonRows, id: \.metric) { row in
                HStack(spacing: Theme.Spacing.x2) {
                    Text(row.metric)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Theme.text)

                    Text(row.thisWeek)
                        .frame(width: 84, alignment: .leading)
                        .foregroundStyle(Theme.text)
                        .tabularNumbers()

                    Text(row.lastWeek)
                        .frame(width: 84, alignment: .leading)
                        .foregroundStyle(Theme.muted)
                        .tabularNumbers()
                }
                .font(Theme.TypeScale.row)
                .padding(.vertical, Theme.Spacing.x2)
                .overlay(alignment: .bottom) { RuleView() }
                .accessibilityElement(children: .combine)
            }

            SecondaryButton(title: "Share this week as a summary") {
                model.flash("Summary ready to share")
            }
            .padding(.top, Theme.Spacing.x4)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, Theme.Spacing.gutter)
    }
}

#Preview {
    ScrollView {
        TrendsView(model: BaselineViewModel())
    }
    .background(Theme.background)
}
