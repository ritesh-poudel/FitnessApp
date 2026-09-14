//
//  ProgressBarView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Flat, square-cornered progress track. The modernist replacement for `ProgressView`.
///
/// The design draws this as a 10px neutral-300 field with an accent fill.
struct ProgressBarView: View {
    let value: Double
    var color: Color = Theme.accent
    var track: Color = Theme.Neutral.n300
    var height: CGFloat = 10

    private var clamped: Double { min(max(value, 0), 1) }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(track)

                Rectangle()
                    .fill(color)
                    .frame(width: proxy.size.width * clamped)
            }
        }
        .frame(height: height)
        .animation(Theme.Motion.progress, value: clamped)
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressBarView(value: 0.3)
        ProgressBarView(value: 0.84)
    }
    .padding()
    .background(Theme.background)
}
