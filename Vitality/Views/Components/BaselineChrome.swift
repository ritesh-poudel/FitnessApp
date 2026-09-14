//
//  BaselineChrome.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The fixed masthead: the wordmark and today's date over a 2px rule.
struct BaselineHeader: View {
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.x3) {
            Text("BASELINE")
                .font(.system(size: 15, weight: .heavy))
                .kerning(15 * 0.16)
                .foregroundStyle(Theme.text)

            Spacer(minLength: Theme.Spacing.x2)

            Text(Date.now, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                .kicker(tracking: 0.1)
                .foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, 9)
        .background(Theme.background)
        .overlay(alignment: .bottom) {
            RuleView(weight: Theme.rule)
        }
    }
}

/// An uppercase section head, set above a group.
struct SectionKicker: View {
    let title: String
    /// Optional trailing figure, right-aligned on the same line.
    var trailing: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.x3) {
            Text(title)
                .kicker()
                .foregroundStyle(Theme.muted)

            if let trailing {
                Spacer(minLength: Theme.Spacing.x2)

                Text(trailing)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.muted)
                    .tabularNumbers()
            }
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.top, Theme.Spacing.x4)
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A screen's large title and standfirst.
struct ScreenTitle: View {
    let title: String
    let standfirst: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(Theme.TypeScale.title)
                .kerning(31 * -0.025)
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)

            Text(standfirst)
                .font(Theme.TypeScale.body)
                .foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.gutter)
    }
}

/// The five-tab bar. Square dots, no glyphs — the system draws its own marks.
struct BaselineTabBar: View {
    @Binding var selection: BaselineViewModel.Tab

    var body: some View {
        HStack(spacing: Theme.rule) {
            ForEach(BaselineViewModel.Tab.allCases) { tab in
                let isSelected = selection == tab

                Button {
                    withAnimation(Theme.Motion.state) {
                        selection = tab
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Rectangle()
                            .fill(isSelected ? .white : .clear)
                            .frame(width: 14, height: 14)
                            .overlay {
                                Rectangle()
                                    .strokeBorder(
                                        isSelected ? .white : Theme.muted,
                                        lineWidth: Theme.rule
                                    )
                            }

                        Text(tab.label)
                            .kickerHeavy(tracking: 0.05)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(isSelected ? .white : Theme.muted)
                    .padding(.horizontal, Theme.Spacing.x2)
                    .padding(.top, 11)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .topLeading)
                    .background(isSelected ? Theme.accent : Theme.background)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .background(Theme.divider)
        .overlay(alignment: .top) {
            RuleView(weight: Theme.rule)
        }
    }
}

/// The system's primary action: a full-width flat accent field.
struct PrimaryButton: View {
    let title: String
    var height: CGFloat = 52
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(Theme.background)
                .padding(.horizontal, Theme.Spacing.x4)
                .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
                .background(Theme.accent)
        }
        .buttonStyle(.plain)
    }
}

/// The secondary action: an outlined field with no fill.
struct SecondaryButton: View {
    let title: String
    var height: CGFloat = 48
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, Theme.Spacing.x4)
                .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
                .overlay {
                    Rectangle()
                        .strokeBorder(Theme.divider, lineWidth: Theme.hairline)
                }
        }
        .buttonStyle(.plain)
    }
}

/// A segmented control drawn as abutting square fields sharing one border.
struct SegmentedField<Option: Hashable & Identifiable>: View {
    let options: [Option]
    @Binding var selection: Option
    var height: CGFloat = 44
    let label: (Option) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                let isSelected = selection == option

                Button {
                    withAnimation(Theme.Motion.state) {
                        selection = option
                    }
                } label: {
                    Text(label(option))
                        .font(.system(size: 12, weight: .heavy))
                        .kerning(12 * 0.06)
                        .textCase(.uppercase)
                        .foregroundStyle(isSelected ? Theme.background : Theme.text)
                        .padding(.horizontal, Theme.Spacing.x3)
                        .frame(maxWidth: .infinity, minHeight: height, alignment: .leading)
                        .background(isSelected ? Theme.text : .clear)
                        .overlay {
                            Rectangle()
                                .strokeBorder(Theme.text, lineWidth: Theme.rule)
                                // Only the first segment draws its leading edge,
                                // so neighbours share a single 2px rule.
                                .padding(.leading, index == 0 ? 0 : -Theme.rule)
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .clipped()
    }
}

#Preview {
    @Previewable @State var tab = BaselineViewModel.Tab.today

    VStack(spacing: 0) {
        BaselineHeader()
        ScreenTitle(title: "Good morning, Sam",
                    standfirst: "Three days in a row of moving before noon.")
        Spacer()
        PrimaryButton(title: "Log something") {}
            .padding(Theme.Spacing.gutter)
        BaselineTabBar(selection: $tab)
    }
    .background(Theme.background)
}
