//
//  RuleView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// A hairline rule. Structure in this design comes from rules, not shadows.
struct RuleView: View {
    @Environment(\.colorScheme) private var colorScheme

    var color: Color?
    var weight: CGFloat = Theme.hairline

    var body: some View {
        Rectangle()
            .fill(color ?? Theme.rule(for: colorScheme))
            .frame(height: weight)
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 16) {
        RuleView()
        RuleView(weight: 2)
        RuleView(color: HabitCategory.health.tint, weight: 3)
    }
    .padding()
}
