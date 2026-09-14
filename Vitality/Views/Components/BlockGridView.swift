//
//  BlockGridView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// One day in the four-week grid, graded into four intensity levels.
enum BlockLevel: Int, CaseIterable {
    case none, light, medium, full

    var fill: Color {
        switch self {
        case .none: Theme.Neutral.n200
        case .light: Theme.Accent.a300
        case .medium: Theme.Accent.a500
        case .full: Theme.accent
        }
    }

    /// Empty days carry a hairline ring so they read as cells, not gaps.
    var ring: Color? {
        self == .none ? Theme.Neutral.n300 : nil
    }

    /// Any shaded day counts as the goal being met.
    var isMet: Bool { self != .none }
}

/// Four weeks of days as a 7-column block grid — the long view, where streaks
/// and gaps read instantly without depending on any number.
struct BlockGridView: View {
    let title: String
    let levels: [BlockLevel]

    private var metCount: Int {
        levels.filter(\.isMet).count
    }

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .kicker()
                .foregroundStyle(Theme.muted)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                    Rectangle()
                        .fill(level.fill)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            if let ring = level.ring {
                                Rectangle()
                                    .strokeBorder(ring, lineWidth: Theme.hairline)
                            }
                        }
                }
            }
            .padding(.top, Theme.Spacing.x3)

            legend
                .padding(.top, 14)

            Text("For the long view: streaks and gaps read instantly, and nothing depends on reading a number.")
                .font(.system(size: 12))
                .lineSpacing(3)
                .foregroundStyle(Theme.muted)
                .padding(.top, 14)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(metCount) of \(levels.count) days met")
    }

    private var legend: some View {
        HStack(spacing: Theme.Spacing.x2) {
            Text("Less")
                .kicker(tracking: 0.1)
                .foregroundStyle(Theme.muted)

            ForEach(BlockLevel.allCases, id: \.rawValue) { level in
                Rectangle()
                    .fill(level.fill)
                    .frame(width: 16, height: 16)
                    .overlay {
                        if let ring = level.ring {
                            Rectangle()
                                .strokeBorder(ring, lineWidth: Theme.hairline)
                        }
                    }
            }

            Text("More")
                .kicker(tracking: 0.1)
                .foregroundStyle(Theme.muted)

            Spacer(minLength: Theme.Spacing.x2)

            Text("\(metCount) of \(levels.count) days met")
                .font(.system(size: 11))
                .tabularNumbers()
                .foregroundStyle(Theme.muted)
        }
        .accessibilityHidden(true)
    }
}

extension BlockLevel {
    /// The last four weeks of move-goal days.
    static let lastFourWeeks: [BlockLevel] = [
        0, 2, 3, 1, 3, 0, 2,
        1, 3, 3, 2, 3, 1, 0,
        2, 3, 1, 3, 3, 2, 1,
        3, 3, 2, 3, 1, 0, 2
    ].map { BlockLevel(rawValue: $0) ?? .none }
}

#Preview {
    BlockGridView(
        title: "Move goal, last four weeks",
        levels: BlockLevel.lastFourWeeks
    )
    .background(Theme.background)
}
