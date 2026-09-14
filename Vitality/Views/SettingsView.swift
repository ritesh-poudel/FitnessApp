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
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                    group("App Information") {
                        row("App Name", value: AppConstants.appName)
                        row("Version", value: AppConstants.version)
                    }

                    group("Tracking") {
                        row("Habits Tracked", value: "\(viewModel.habits.count)")
                        row("Completed Today", value: "\(viewModel.completedCount)")
                    }

                    group("About") {
                        Link(destination: AppConstants.websiteURL) {
                            HStack {
                                Text("Website")
                                    .font(.system(.body, weight: .medium))
                                    .foregroundStyle(Theme.ink(for: colorScheme))

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(height: 28)
                        }
                    }

                    resetButton
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.canvas(for: colorScheme))
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

    // MARK: - Building Blocks

    /// A titled block: uppercase head, rule, then rows. Replaces the grouped `List` section.
    private func group<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(title)
                .labelStyle()
                .foregroundStyle(.secondary)

            RuleView(color: Theme.ink(for: colorScheme), weight: 2)

            content()
        }
    }

    private func row(_ title: String, value: String) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            HStack {
                Text(title)
                    .font(.system(.body, weight: .medium))
                    .foregroundStyle(Theme.ink(for: colorScheme))

                Spacer()

                Text(value)
                    .font(.system(.body, weight: .semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(.secondary)
            }
            .frame(height: 28)

            RuleView()
        }
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            isConfirmingReset = true
        } label: {
            Text("Reset All Data")
                .labelStyle()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(HabitCategory.health.tint)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
