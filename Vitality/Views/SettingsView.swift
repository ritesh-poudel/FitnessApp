//
//  SettingsView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var isConfirmingReset = false

    var body: some View {
        NavigationStack {
            List {
                Section("App Information") {
                    LabeledContent("App Name", value: AppConstants.appName)
                    LabeledContent("Version", value: AppConstants.version)
                }

                Section("Tracking") {
                    LabeledContent("Habits Tracked", value: "\(viewModel.habits.count)")
                    LabeledContent("Completed Today", value: "\(viewModel.completedCount)")
                }

                Section("Actions") {
                    Button(role: .destructive) {
                        isConfirmingReset = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }

                Section("About") {
                    Link(destination: AppConstants.websiteURL) {
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
        .task {
            await viewModel.load()
        }
        .confirmationDialog(
            "Reset all data?",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                Task { await viewModel.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes every habit and its progress.")
        }
    }
}

#Preview {
    SettingsView()
}
