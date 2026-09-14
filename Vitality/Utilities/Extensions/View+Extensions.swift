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
    /// Applies a card style to the view
    func cardStyle() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Hides the keyboard
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}
