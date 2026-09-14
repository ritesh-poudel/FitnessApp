//
//  ContentView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(HabitCategory.health.tint)
    }
}

#Preview {
    ContentView()
}
