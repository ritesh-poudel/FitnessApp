//
//  ContentView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/13/26.
//

import SwiftUI

/// The app's root view. Baseline draws its own header and tab bar, so there is
/// no `TabView` here — the whole chrome belongs to the design system.
struct ContentView: View {
    var body: some View {
        BaselineView()
    }
}

#Preview {
    ContentView()
}
