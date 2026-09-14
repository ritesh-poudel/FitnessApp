//
//  View+Extensions.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension View {
    /// Flat surface bounded by a rule — no corner radius, no shadow.
    /// `accent` swaps the border for the accent color to mark an active state.
    func cardStyle(padding: CGFloat = Theme.Spacing.x4, accent: Color? = nil) -> some View {
        self
            .padding(padding)
            .background(Theme.surface)
            .overlay {
                Rectangle()
                    .strokeBorder(
                        accent ?? Theme.divider,
                        lineWidth: accent == nil ? Theme.hairline : Theme.rule
                    )
            }
            .animation(Theme.Motion.state, value: accent)
    }

    /// Hides the keyboard
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}
