//
//  SettingsView.swift
//  test
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConstants.version)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text(AppConstants.appName)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Actions") {
                    Button(role: .destructive) {
                        // Reset app data
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                
                Section("About") {
                    Link(destination: URL(string: "https://apple.com")!) {
                        HStack {
                            Text("Website")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
