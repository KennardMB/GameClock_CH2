//
//  Palette.swift
//  GameClock_CH2
//
//  One color scheme for the whole app. Four accents spaced evenly on the
//  color wheel so they harmonize, plus shared neutrals for surfaces and text.
//

import SwiftUI

enum Palette {
    // Feature accents
    static let stopwatch = Color(red: 0.96, green: 0.62, blue: 0.04)   // amber
    static let timer     = Color(red: 0.55, green: 0.36, blue: 0.96)   // violet
    static let rubiks    = Color(red: 0.08, green: 0.72, blue: 0.65)   // teal
    static let chess     = Color(red: 0.39, green: 0.40, blue: 0.95)   // indigo

    // Neutrals for immersive dark screens
    static let ink   = Color(red: 0.05, green: 0.06, blue: 0.08)       // near-black background
    static let paper = Color.white                                      // primary content on ink
    static let chalk = Color.white.opacity(0.55)                        // muted text on ink
    static let smoke = Color.white.opacity(0.12)                        // glass panel on ink
}
