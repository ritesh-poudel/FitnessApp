//
//  MetricDetailView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The pushed metric screen: a big readout, a range control, the week's chart,
/// summary statistics, and a plain-language explanation.
struct MetricDetailView: View {
    @Bindable var model: BaselineViewModel
    let metric: MetricSample

    /// The generated reading, once it arrives. Nil means show the written one.
    @State private var generated: String?
    @State private var isGenerating = false

    private var detail: MetricDetail {
        metric.detail(steps: model.steps, units: model.units)
    }

    /// The generated reading when there is one, else the hand-written fallback.
    /// Both render identically, so a failure to generate is invisible.
    private var plainText: String {
        generated ?? detail.plain
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    readout

                    SegmentedField(
                        options: BaselineViewModel.Range.allCases,
                        selection: $model.range
                    ) { $0.rawValue }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.bottom, 14)

                    BarChartView(
                        bars: metric.chartBars(
                            todayOverride: metric == .steps ? Double(model.steps) : nil
                        ),
                        height: 168
                    )
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.bottom, Theme.Spacing.x1)

                    statistics

                    plainWords

                    PrimaryButton(title: detail.callToAction) {
                        model.isSheetPresented = true
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .padding(.bottom, Theme.Spacing.x6)
                }
            }
        }
        .background(Theme.background)
        .task(id: metric) {
            await loadReading()
        }
    }

    /// Asks the server for a reading. Silently keeps the written one on failure.
    private func loadReading() async {
        generated = nil
        isGenerating = true
        defer { isGenerating = false }

        let text = await InsightService.shared.reading(
            for: metric,
            unit: detail.unit,
            aim: model.aim,
            units: model.units
        )

        guard !Task.isCancelled else { return }
        generated = text
    }

    // MARK: - Navigation

    private var navigationBar: some View {
        HStack {
            Button {
                withAnimation(model.reduceMotion ? nil : Theme.Motion.push) {
                    model.detail = nil
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .heavy))

                    Text("Today")
                        .font(.system(size: 13, weight: .heavy))
                        .kerning(13 * 0.06)
                }
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, Theme.Spacing.x1)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, 9)
        .background(Theme.background)
        .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Readout

    private var readout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(detail.kicker)
                .kicker()
                .foregroundStyle(Theme.muted)

            Text(detail.label)
                .font(Theme.TypeScale.titleDetail)
                .kerning(29 * -0.025)
                .foregroundStyle(Theme.text)
                .padding(.top, 4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .bottom, spacing: Theme.Spacing.x2) {
                Text(detail.value)
                    .font(Theme.TypeScale.readout)
                    .kerning(64 * -0.04)
                    .tabularNumbers()
                    .contentTransition(.numericText())
                    .foregroundStyle(Theme.text)

                Text(detail.unit)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.muted)
                    .padding(.bottom, 8)
            }
            .padding(.top, Theme.Spacing.x3)
            .animation(Theme.Motion.progress, value: detail.value)

            Text(detail.delta)
                .font(.system(size: 12.5))
                .foregroundStyle(Theme.Accent.a700)
                .padding(.top, 6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.top, Theme.Spacing.gutter)
        .padding(.bottom, 14)
    }

    // MARK: - Statistics

    private var statistics: some View {
        VStack(spacing: 0) {
            ForEach(detail.stats, id: \.key) { stat in
                HStack(spacing: Theme.Spacing.x3) {
                    Text(stat.key)
                        .kicker(size: 12, tracking: 0.06)
                        .foregroundStyle(Theme.muted)

                    Spacer(minLength: Theme.Spacing.x2)

                    Text(stat.value)
                        .font(.system(size: 14, weight: .heavy))
                        .tabularNumbers()
                        .foregroundStyle(Theme.text)
                }
                .padding(.vertical, Theme.Spacing.x2)
                .overlay(alignment: .bottom) { RuleView() }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(Theme.Spacing.gutter)
    }

    // MARK: - Plain Words

    /// The design's core idea: a number is only useful once something explains it.
    private var plainWords: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: Theme.Spacing.x2) {
                Text("In plain words")
                    .kicker()
                    .foregroundStyle(Theme.Accent.a700)

                if isGenerating {
                    // A 2px bar rather than a spinner — the system has no
                    // circular forms anywhere else.
                    Rectangle()
                        .fill(Theme.Accent.a700)
                        .frame(width: 18, height: 2)
                        .opacity(0.5)
                        .transition(.opacity)
                        .accessibilityHidden(true)
                }
            }
            .animation(Theme.Motion.state, value: isGenerating)

            Text(plainText)
                .font(.system(size: 13.5))
                .lineSpacing(3)
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
                .animation(Theme.Motion.state, value: plainText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.text)
                .frame(height: Theme.rule)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, Theme.Spacing.gutter)
    }
}

#Preview {
    MetricDetailView(model: BaselineViewModel(), metric: .steps)
}
