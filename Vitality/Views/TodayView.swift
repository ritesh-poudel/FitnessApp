//
//  TodayView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The Today tab: a readiness masthead, six metric tiles, and the secondary rows.
struct TodayView: View {
    @Bindable var model: BaselineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenTitle(
                title: model.greeting,
                standfirst: "Three days in a row of moving before noon. Keep it going."
            )

            readiness

            tiles

            SectionKicker(title: "Also logged today")

            secondaryRows

            logSomething
        }
    }

    // MARK: - Readiness

    /// The one accent field on this screen: an oversized score over a
    /// seven-day trend.
    private var readiness: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today's readiness")
                .kicker(tracking: 0.14)
                .foregroundStyle(.white)

            HStack(alignment: .bottom, spacing: Theme.Spacing.x3) {
                Text("\(model.readiness)")
                    .font(Theme.TypeScale.display)
                    .kerning(74 * -0.04)
                    .tabularNumbers()
                    .contentTransition(.numericText())
                    .foregroundStyle(.white)
                    .animation(Theme.Motion.progress, value: model.readiness)

                Text("out of 100. Your sleep and resting heart rate both look good.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 170, alignment: .leading)
                    .padding(.bottom, 7)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            // The trend reads as white bars at varying opacity, so it stays
            // legible on the accent field without a second colour.
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(model.readinessBars) { bar in
                    Rectangle()
                        .fill(.white)
                        .opacity(bar.isToday ? 1 : 0.55)
                        .frame(maxWidth: .infinity)
                        .frame(height: max(34 * bar.fraction, 2))
                }
            }
            .frame(height: 34, alignment: .bottom)
            .padding(.top, Theme.Spacing.x3)
            .accessibilityHidden(true)

            Text("Last 7 days")
                .kicker(size: 10, tracking: 0.1)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 6)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.top, Theme.Spacing.x4)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.accent)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's readiness, \(model.readiness) out of 100")
    }

    // MARK: - Tiles

    /// Two columns of tiles, separated by the divider showing through 2px gaps.
    private var tiles: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Theme.rule),
                GridItem(.flexible(), spacing: Theme.rule)
            ],
            spacing: Theme.rule
        ) {
            ForEach(model.tiles) { tile in
                Button {
                    model.detail = tile.metric
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tile.label)
                            .kicker(size: 10, tracking: 0.11)
                            .foregroundStyle(Theme.muted)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(tile.value)
                                .font(Theme.TypeScale.tile)
                                .kerning(31 * -0.03)
                                .tabularNumbers()
                                .contentTransition(.numericText())
                                .foregroundStyle(Theme.text)

                            Text(tile.unit)
                                .font(.system(size: 11.5))
                                .foregroundStyle(Theme.muted)
                        }
                        .animation(Theme.Motion.progress, value: tile.value)

                        Spacer(minLength: 0)

                        Text(tile.delta)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.Accent.a700)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 13)
                    .padding(.bottom, 11)
                    .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
                    .background(Theme.background)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(tile.label), \(tile.value) \(tile.unit)")
                .accessibilityHint(tile.delta)
            }
        }
        .background(Theme.divider)
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
        .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Secondary Rows

    private var secondaryRows: some View {
        VStack(spacing: 0) {
            ForEach(model.secondaryRows) { row in
                Button {
                    model.detail = row.metric
                } label: {
                    HStack(spacing: Theme.Spacing.x3) {
                        Text(row.label)
                            .font(Theme.TypeScale.row)
                            .foregroundStyle(Theme.text)

                        Spacer(minLength: Theme.Spacing.x2)

                        Text(row.value)
                            .font(Theme.TypeScale.rowValue)
                            .tabularNumbers()
                            .foregroundStyle(Theme.text)

                        Text(row.unit)
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.muted)
                            .frame(width: 46, alignment: .leading)

                        Chevron()
                    }
                    .padding(.horizontal, Theme.Spacing.gutter)
                    .frame(minHeight: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(row.label), \(row.value) \(row.unit)")

                RuleView()
            }
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Log

    private var logSomething: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrimaryButton(title: "Log something") {
                model.isSheetPresented = true
            }

            Text("A walk, a glass of water, how you feel — it all counts.")
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.gutter)
    }
}

/// The disclosure mark used on every pushable row.
struct Chevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(Theme.Neutral.n600)
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        TodayView(model: BaselineViewModel())
    }
    .background(Theme.background)
}
