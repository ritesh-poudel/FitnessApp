//
//  ProfileView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The You tab: identity, accessibility switches, units, and data controls.
struct ProfileView: View {
    @Bindable var model: BaselineViewModel
    @State private var isConfirmingReset = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            identity

            SectionKicker(title: "Make it easier to read")

            accessibility

            SectionKicker(title: "Units")

            units

            SectionKicker(title: "Your data")

            dataRows

            VStack(spacing: Theme.Spacing.x2) {
                SecondaryButton(title: "Sign out") {
                    model.flash("Signed out")
                }

                // Destructive, so it takes the accent field and a confirmation.
                Button {
                    isConfirmingReset = true
                } label: {
                    Text("Reset all data")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Theme.background)
                        .padding(.horizontal, Theme.Spacing.x4)
                        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                        .background(Theme.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(Theme.Spacing.gutter)
        }
        .confirmationDialog(
            "Reset all data?",
            isPresented: $isConfirmingReset,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) {
                Task { await model.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes every habit and its progress.")
        }
    }

    // MARK: - Identity

    private var identity: some View {
        HStack(spacing: 14) {
            // Initials set in reversed ink — the system's stand-in for an avatar.
            Text("SR")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(Theme.background)
                .frame(width: 64, height: 64)
                .background(Theme.text)

            VStack(alignment: .leading, spacing: 3) {
                Text("Sam Reyes")
                    .font(.system(size: 24, weight: .heavy))
                    .kerning(24 * -0.02)
                    .foregroundStyle(Theme.text)

                Text("Tracking since March 2024 · 418 days logged")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.gutter)
        .overlay(alignment: .bottom) { RuleView(weight: Theme.rule) }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Accessibility

    private var accessibility: some View {
        VStack(spacing: 0) {
            ToggleRow(
                label: "Bigger text",
                sublabel: "Scales everything up, nothing gets cut off",
                isOn: Binding(
                    get: { model.largeType },
                    set: { newValue in
                        withAnimation(Theme.Motion.state) { model.largeType = newValue }
                        model.flash(newValue ? "Text enlarged" : "Text back to normal")
                    }
                )
            )
            RuleView()

            ToggleRow(
                label: "Stronger contrast",
                sublabel: "Heavier rules and darker labels",
                isOn: Binding(
                    get: { model.strongContrast },
                    set: { newValue in
                        model.strongContrast = newValue
                        model.flash(newValue ? "Contrast increased" : "Contrast normal")
                    }
                )
            )
            RuleView()

            ToggleRow(
                label: "Reduce motion",
                sublabel: "Screens change without sliding",
                isOn: Binding(
                    get: { model.reduceMotion },
                    set: { newValue in
                        model.reduceMotion = newValue
                        model.flash(newValue ? "Motion reduced" : "Motion on")
                    }
                )
            )
            RuleView()
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    // MARK: - Units

    private var units: some View {
        SegmentedField(
            options: UnitSystem.allCases,
            selection: Binding(
                get: { model.units },
                set: { newValue in
                    model.units = newValue
                    model.flash("Now showing \(newValue.label.lowercased())")
                }
            ),
            height: 48
        ) { $0.label }
        .padding(.horizontal, Theme.Spacing.gutter)
        .padding(.bottom, Theme.Spacing.x1)
    }

    // MARK: - Data

    private var dataRows: some View {
        VStack(spacing: 0) {
            dataRow(label: "Connected devices", value: "2")
            dataRow(label: "Export my data", value: "CSV or PDF")
            dataRow(label: "Share with a clinician", value: "Off")
            dataRow(label: "Delete history", value: "")
        }
        .overlay(alignment: .top) { RuleView(weight: Theme.rule) }
    }

    private func dataRow(label: String, value: String) -> some View {
        HStack(spacing: Theme.Spacing.x3) {
            Text(label)
                .font(Theme.TypeScale.row)
                .foregroundStyle(Theme.text)

            Spacer(minLength: Theme.Spacing.x2)

            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(Theme.muted)

            Chevron()
        }
        .padding(.horizontal, Theme.Spacing.gutter)
        .frame(minHeight: 56)
        .overlay(alignment: .bottom) { RuleView() }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ScrollView {
        ProfileView(model: BaselineViewModel())
    }
    .background(Theme.background)
}
