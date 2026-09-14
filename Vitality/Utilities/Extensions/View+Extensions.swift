//
//  View+Extensions.swift
//  test
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension View {
    /// Flat surface bounded by a hairline rule — no corner radius, no shadow.
    /// `accent` swaps the border for a category color to mark an active state.
    func cardStyle(padding: CGFloat = Theme.Spacing.lg, accent: Color? = nil) -> some View {
        modifier(SurfaceModifier(padding: padding, accent: accent))
    }

    /// Hides the keyboard
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

/// Backs `cardStyle()`. A modifier rather than an inline chain so it can read the color scheme.
private struct SurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let padding: CGFloat
    let accent: Color?

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.surface(for: colorScheme))
            .overlay {
                Rectangle()
                    .strokeBorder(
                        accent ?? Theme.rule(for: colorScheme),
                        lineWidth: accent == nil ? Theme.hairline : 2
                    )
            }
            .animation(Theme.Motion.state, value: accent)
    }
}
