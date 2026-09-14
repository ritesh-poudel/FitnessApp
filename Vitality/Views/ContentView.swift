//
//  ContentView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/13/26.
//

import SwiftUI

/// The app's root. Shows onboarding until it has been completed once, then
/// the Baseline tabs. Baseline draws its own header and tab bar, so there is
/// no `TabView` here — the whole chrome belongs to the design system.
struct ContentView: View {
    @State private var hasOnboarded: Bool?

    private let storage: StorageService = .shared

    var body: some View {
        Group {
            switch hasOnboarded {
            case .some(true):
                BaselineView()

            case .some(false):
                OnboardingView {
                    withAnimation(Theme.Motion.push) {
                        hasOnboarded = true
                    }
                }

            case nil:
                // Holds the ground colour while the flag is read, so the app
                // never flashes a different screen on launch.
                Theme.background
                    .ignoresSafeArea()
            }
        }
        .task {
            hasOnboarded = await storage.hasOnboarded()
        }
    }
}

#Preview {
    ContentView()
}
