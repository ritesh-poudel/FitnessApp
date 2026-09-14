//
//  DashboardView.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    summary

                    ForEach(HabitCategory.allCases) { category in
                        let habits = viewModel.habits(in: category)
                        if !habits.isEmpty {
                            section(for: category, habits: habits)
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Today")
        }
        .task {
            await viewModel.load()
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily progress")
                .font(.headline)

            ProgressView(value: viewModel.dayProgress)
                .tint(.accentColor)

            Text("\(viewModel.completedCount) of \(viewModel.habits.count) goals met")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func section(for category: HabitCategory, habits: [Habit]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(category.displayName, systemImage: category.symbolName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(category.tint)

            ForEach(habits) { habit in
                HabitCardView(
                    habit: habit,
                    onLog: { Task { await viewModel.logCompletion(for: habit) } },
                    onUndo: { Task { await viewModel.undoCompletion(for: habit) } }
                )
            }
        }
    }
}

#Preview {
    DashboardView()
}
