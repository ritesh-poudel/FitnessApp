//
//  TimeBlock.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import SwiftUI

/// One entry in the day's schedule on the Plan tab.
struct TimeBlock: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let label: String
    let sublabel: String
    let state: State

    enum State: String, Hashable {
        case done = "Done"
        case now = "Now"
        case next = "Next"
        case upcoming = ""

        /// The current block is the one place the accent appears in this list.
        var background: Color {
            self == .now ? Theme.Accent.a200 : Theme.background
        }

        var rule: Color {
            self == .now ? Theme.accent : Theme.Neutral.n300
        }

        var timeInk: Color {
            self == .done ? Theme.muted : Theme.text
        }

        var stateInk: Color {
            self == .now ? Theme.Accent.a700 : Theme.muted
        }
    }

    /// The sample day shown on the Plan tab. These are not persisted yet —
    /// scheduling is a feature the design proposes but the app does not store.
    static let sampleDay: [TimeBlock] = [
        TimeBlock(time: "07:00", label: "Wake and walk",
                  sublabel: "Daylight early keeps sleep on track", state: .done),
        TimeBlock(time: "09:30", label: "Deep work",
                  sublabel: "Quarterly review · two focus sessions", state: .now),
        TimeBlock(time: "12:30", label: "Lunch away from the desk",
                  sublabel: "A short walk after helps", state: .next),
        TimeBlock(time: "15:00", label: "Admin and replies",
                  sublabel: "Low-energy hour, low-stakes work", state: .upcoming),
        TimeBlock(time: "18:30", label: "Easy 5k",
                  sublabel: "Keep it conversational", state: .upcoming),
        TimeBlock(time: "22:30", label: "Wind-down",
                  sublabel: "Screens off, reading on", state: .upcoming)
    ]

    /// The block the summary line points at.
    static let nextUp = "12:30 lunch"
}
