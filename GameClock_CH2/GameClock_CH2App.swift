//
//  GameClock_CH2App.swift
//  GameClock_CH2
//
//  Created by Kennard M on 19/04/26.
//
import SwiftData
import SwiftUI

@main
struct GameClock_CH2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Solve.self)
    }
}
