//
//  Theme.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// Design tokens for the Modernist system: Archivo throughout, zero radius,
/// 2px rules instead of shadows, and red used as a field once per screen.
///
/// Values are lifted from the design system's `styles.css` and are deliberately
/// not rounded to a grid — the ramps were generated in OKLCH on one shared
/// lightness scale, so a step of any role matches the others in visual value.
enum Theme {
    // MARK: - Spacing

    /// A 4pt base unit. Every gap in the UI is a multiple of it.
    enum Spacing {
        static let unit: CGFloat = 4
        static let x1: CGFloat = 4
        static let x2: CGFloat = 8
        static let x3: CGFloat = 12
        static let x4: CGFloat = 16
        static let x6: CGFloat = 24
        static let x8: CGFloat = 32

        /// The screen gutter used by every full-width row and heading.
        static let gutter: CGFloat = 18
    }

    // MARK: - Shape

    enum Radius {
        /// The Modernist system is square. All three radius tokens are 0.
        static let sm: CGFloat = 0
        static let md: CGFloat = 0
        static let lg: CGFloat = 0
    }

    // MARK: - Rules

    /// Hairline rule, used between rows within a group.
    static let hairline: CGFloat = 1
    /// Heavy rule, used to bound a group. The system's structural line.
    static let rule: CGFloat = 2

    // MARK: - Motion

    enum Motion {
        /// Used whenever a count or progress value changes.
        static let progress: Animation = .spring(response: 0.4, dampingFraction: 0.85)
        /// Used for appearance and state toggles.
        static let state: Animation = .snappy(duration: 0.22)
        /// Push navigation and sheet presentation, matching the design's
        /// cubic-bezier(.32,.72,0,1) easing.
        static let push: Animation = .timingCurve(0.32, 0.72, 0, 1, duration: 0.28)
    }

    // MARK: - Color

    /// Page ground.
    static let background = Color(hex: 0xf3f2f2)
    /// Raised surface sitting on the ground.
    static let surface = Color(hex: 0xeae9e9)
    /// Primary ink.
    static let text = Color(hex: 0x201e1d)
    /// The single accent. Used as a flat field, once per screen.
    static let accent = Color(hex: 0xec3013)
    static let accent2 = Color(hex: 0xe15b47)
    /// Divider — ink at 40%.
    static let divider = Color(hex: 0x201e1d).opacity(0.4)

    /// Neutral ramp.
    enum Neutral {
        static let n100 = Color(hex: 0xf8f4f4)
        static let n200 = Color(hex: 0xeae7e7)
        static let n300 = Color(hex: 0xd7d3d3)
        static let n400 = Color(hex: 0xbab6b6)
        static let n500 = Color(hex: 0x9b9797)
        static let n600 = Color(hex: 0x7d7979)
        static let n700 = Color(hex: 0x605d5d)
        static let n800 = Color(hex: 0x444141)
        static let n900 = Color(hex: 0x2d2b2b)
    }

    /// Accent ramp.
    enum Accent {
        static let a100 = Color(hex: 0xfff2ef)
        static let a200 = Color(hex: 0xffe0d9)
        static let a300 = Color(hex: 0xffc4b8)
        static let a400 = Color(hex: 0xff9783)
        static let a500 = Color(hex: 0xff563c)
        static let a600 = Color(hex: 0xdd2b0f)
        static let a700 = Color(hex: 0xae1800)
        static let a800 = Color(hex: 0x7c1405)
        static let a900 = Color(hex: 0x4d170e)
    }

    /// Muted body text, used for every secondary line in the design.
    static let muted = Neutral.n700

    // MARK: - Type

    /// Archivo is the system's face at 400/600/800. It is not bundled, so the
    /// app falls back to the system face at matching weights; `heading` carries
    /// the 800 weight and tight tracking that define the look.
    enum TypeScale {
        /// Screen title — 31px/800, -0.025em.
        static let title = Font.system(size: 31, weight: .heavy)
        /// Detail screen title — 29px/800.
        static let titleDetail = Font.system(size: 29, weight: .heavy)
        /// Sheet title — 22px/800.
        static let sheetTitle = Font.system(size: 22, weight: .heavy)
        /// Oversized readout — 74px/800, used once per screen.
        static let display = Font.system(size: 74, weight: .heavy)
        /// Focus clock — 70px/800.
        static let clock = Font.system(size: 70, weight: .heavy)
        /// Detail readout — 64px/800.
        static let readout = Font.system(size: 64, weight: .heavy)
        /// Tile numeral — 31px/800.
        static let tile = Font.system(size: 31, weight: .heavy)
        /// Week-line numeral — 34px/800.
        static let weekNumeral = Font.system(size: 34, weight: .heavy)
        /// Streak numeral — 30px/800.
        static let streak = Font.system(size: 30, weight: .heavy)
        /// Row value — 17px/800.
        static let rowValue = Font.system(size: 17, weight: .heavy)
        /// Body copy — 13px/400.
        static let body = Font.system(size: 13)
        /// Row label — 14px/400.
        static let row = Font.system(size: 14)
    }

    /// Uppercase kerned label — 10.5px, 0.12em tracking. The system's section head.
    struct Kicker: ViewModifier {
        var size: CGFloat = 10.5
        var tracking: CGFloat = 0.12

        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: .regular))
                .textCase(.uppercase)
                .kerning(size * tracking)
        }
    }

    /// Uppercase kerned label at heading weight, for tab bars and buttons.
    struct KickerHeavy: ViewModifier {
        var size: CGFloat = 10.5
        var tracking: CGFloat = 0.1

        func body(content: Content) -> some View {
            content
                .font(.system(size: size, weight: .heavy))
                .textCase(.uppercase)
                .kerning(size * tracking)
        }
    }
}

extension View {
    /// Uppercase kerned label at body weight.
    func kicker(size: CGFloat = 10.5, tracking: CGFloat = 0.12) -> some View {
        modifier(Theme.Kicker(size: size, tracking: tracking))
    }

    /// Uppercase kerned label at heading weight.
    func kickerHeavy(size: CGFloat = 10.5, tracking: CGFloat = 0.1) -> some View {
        modifier(Theme.KickerHeavy(size: size, tracking: tracking))
    }

    /// Tabular figures, so numerals do not jitter as they change.
    func tabularNumbers() -> some View {
        monospacedDigit()
    }
}

extension Color {
    /// Builds a color from a `0xRRGGBB` literal, so tokens read as they do in CSS.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: 1
        )
    }
}

extension HabitCategory {
    /// The Modernist system uses one accent, so both categories share it.
    /// Category is carried by the label, not by hue.
    var accent: Color { Theme.accent }
}
