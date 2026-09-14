//
//  HabitCategory.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// The two domains the app tracks, plus the presentation details for each.
enum HabitCategory: String, Codable, CaseIterable, Identifiable {
    case health
    case productivity

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .health: "Health"
        case .productivity: "Productivity"
        }
    }

    var symbolName: String {
        switch self {
        case .health: "heart.fill"
        case .productivity: "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .health: .pink
        case .productivity: .indigo
        }
    }
}
