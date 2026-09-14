//
//  RuleView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// A rule. Structure in this design comes from rules, not shadows.
///
/// The system uses two weights: a 1px hairline between rows inside a group,
/// and a 2px rule bounding the group itself.
struct RuleView: View {
    var color: Color = Theme.divider
    var weight: CGFloat = Theme.hairline

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: weight)
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 16) {
        RuleView()
        RuleView(weight: Theme.rule)
        RuleView(color: Theme.accent, weight: Theme.rule)
    }
    .padding()
    .background(Theme.background)
}
