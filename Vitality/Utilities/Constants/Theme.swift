//
//  Theme.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Design tokens for the app's Swiss-modernist visual language:
/// a strict grid, hairline rules instead of shadows, and a single accent per category.
enum Theme {
    // MARK: - Spacing

    /// A 4pt base unit. Every gap in the UI is a multiple of it.
    enum Spacing {
        static let unit: CGFloat = 4
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 40
    }

    // MARK: - Shape

    enum Radius {
        /// Modernist surfaces are square; only controls get a slight softening.
        static let control: CGFloat = 4
    }

    /// Width of every divider and border in the app.
    static let hairline: CGFloat = 1

    // MARK: - Motion

    enum Motion {
        /// Used whenever a count or progress value changes.
        static let progress: Animation = .spring(response: 0.4, dampingFraction: 0.85)
        /// Used for appearance and state toggles.
        static let state: Animation = .snappy(duration: 0.22)
    }

    // MARK: - Type

    /// Uppercase label style used for every section head and metadata line.
    struct Label: ViewModifier {
        var weight: Font.Weight = .bold

        func body(content: Content) -> some View {
            content
                .font(.system(.caption, design: .default, weight: weight))
                .textCase(.uppercase)
                .kerning(1.2)
        }
    }

    // MARK: - Color

    /// Flat page background — paper in light, near-black in dark.
    static func canvas(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.04) : Color(white: 0.97)
    }

    /// Surface sitting on the canvas. Flat, distinguished by its rule, not a shadow.
    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.09) : .white
    }

    /// Hairline rule color.
    static func rule(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 1, opacity: 0.16) : Color(white: 0, opacity: 0.14)
    }

    /// Ink for primary type.
    static func ink(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(white: 0.96) : Color(white: 0.06)
    }
}

extension View {
    /// Applies the uppercase modernist label treatment.
    func labelStyle(weight: Font.Weight = .bold) -> some View {
        modifier(Theme.Label(weight: weight))
    }
}

extension HabitCategory {
    /// The single flat accent for this category. No gradients in the Swiss system.
    var accent: Color {
        switch self {
        case .health: Color(red: 0.90, green: 0.22, blue: 0.20)      // signal red
        case .productivity: Color(red: 0.08, green: 0.36, blue: 0.86) // signal blue
        }
    }
}
