//
//  BarChartView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// One column of the weekly bar chart.
struct ChartBar: Identifiable {
    let id = UUID()
    /// Single-letter day initial shown under the column.
    let day: String
    /// Formatted value shown above the column.
    let caption: String
    /// Column height as a share of the plot, 0...1.
    let fraction: Double
    /// Today's column is filled in accent; the rest are neutral.
    let isToday: Bool

    var fill: Color { isToday ? Theme.accent : Theme.Neutral.n400 }
    var captionInk: Color { isToday ? Theme.Accent.a700 : Theme.muted }
}

/// A week of bars with a value caption above each and a day initial below,
/// bounded by a 2px rule at the baseline.
struct BarChartView: View {
    let bars: [ChartBar]
    var height: CGFloat = 132
    /// Captions are hidden on the compact readiness chart.
    var showsCaptions = true
    var showsDayLabels = true

    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(bars) { bar in
                    VStack(spacing: 4) {
                        if showsCaptions {
                            Text(bar.caption)
                                .font(.system(size: 9.5))
                                .foregroundStyle(bar.captionInk)
                                .tabularNumbers()
                        }

                        Spacer(minLength: 0)

                        Rectangle()
                            .fill(bar.fill)
                            .frame(height: max(height * bar.fraction, 2))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: height)
            .overlay(alignment: .bottom) {
                RuleView(weight: Theme.rule)
            }

            if showsDayLabels {
                HStack(spacing: 6) {
                    ForEach(bars) { bar in
                        Text(bar.day)
                            .font(.system(size: 10.5))
                            .kerning(10.5 * 0.06)
                            .foregroundStyle(Theme.muted)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    BarChartView(bars: MetricSample.steps.chartBars())
        .padding(Theme.Spacing.gutter)
        .background(Theme.background)
}
