//
//  ProgressBarView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Flat, square-cornered progress track. The modernist replacement for `ProgressView`.
struct ProgressBarView: View {
    let value: Double
    var color: Color
    var height: CGFloat = 6

    private var clamped: Double { min(max(value, 0), 1) }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color.opacity(0.16))

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
        ProgressBarView(value: 0.3, color: HabitCategory.health.tint)
        ProgressBarView(value: 0.8, color: HabitCategory.productivity.tint)
    }
    .padding()
}
