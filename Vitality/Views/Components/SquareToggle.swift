//
//  SquareToggle.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The system's switch: a 56×32 square track with a 2px ink border and a
/// 22×22 knob. Zero radius, like everything else.
struct SquareToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 0) {
            if isOn { Spacer(minLength: 0) }

            Rectangle()
                .fill(isOn ? .white : Theme.text)
                .frame(width: 22, height: 22)

            if !isOn { Spacer(minLength: 0) }
        }
        .padding(3)
        .frame(width: 56, height: 32)
        .background(isOn ? Theme.accent : Theme.background)
        .overlay {
            Rectangle()
                .strokeBorder(Theme.text, lineWidth: Theme.rule)
        }
        .animation(Theme.Motion.state, value: isOn)
    }
}

/// A full-width settings row that toggles when tapped anywhere.
struct ToggleRow: View {
    let label: String
    let sublabel: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: Theme.Spacing.x3) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(Theme.TypeScale.row)
                        .foregroundStyle(Theme.text)

                    Text(sublabel)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: Theme.Spacing.x3)

                SquareToggle(isOn: $isOn)
            }
            .padding(.horizontal, Theme.Spacing.gutter)
            .frame(minHeight: 62)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(sublabel)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

/// Rows tint on press rather than fading, matching the design's hover fill.
struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Theme.Neutral.n200 : Theme.background)
    }
}

#Preview {
    @Previewable @State var on = true
    @Previewable @State var off = false

    VStack(spacing: 0) {
        ToggleRow(label: "Morning nudge", sublabel: "A gentle 8:30am hello", isOn: $on)
        RuleView()
        ToggleRow(label: "Wind-down", sublabel: "30 minutes before bedtime", isOn: $off)
    }
    .background(Theme.background)
}
