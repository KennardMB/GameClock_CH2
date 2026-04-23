//
//  StopwatchView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI
import UIKit

struct StopwatchView: View {
    @State private var startTime = Date()
    @State private var accumulated: TimeInterval = 0
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            TimelineView(.animation(paused: !isRunning)) { context in
                let elapsed = isRunning
                    ? accumulated + context.date.timeIntervalSince(startTime)
                    : accumulated

                Text(format(elapsed))
                    .font(.system(size: 84, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }

            Spacer()

            HStack {
                CircleButton(
                    title: "Reset",
                    foreground: .primary,
                    background: Color(.secondarySystemFill),
                    stroke: Color(.separator)
                ) {
                    reset()
                }
                .opacity(accumulated == 0 && !isRunning ? 0.4 : 1)
                .disabled(accumulated == 0 && !isRunning)

                Spacer()

                CircleButton(
                    title: isRunning ? "Pause" : "Start",
                    foreground: Palette.stopwatch,
                    background: Palette.stopwatch.opacity(isRunning ? 0.25 : 0.18),
                    stroke: Palette.stopwatch.opacity(0.5)
                ) {
                    isRunning ? pause() : start()
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    private func start() {
        startTime = Date()
        isRunning = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func pause() {
        accumulated += Date().timeIntervalSince(startTime)
        isRunning = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func reset() {
        isRunning = false
        accumulated = 0
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func format(_ t: TimeInterval) -> String {
        let minutes = Int(t) / 60
        let seconds = Int(t) % 60
        let hundredths = Int((t * 100).truncatingRemainder(dividingBy: 100))
        return String(format: "%02d:%02d.%02d", minutes, seconds, hundredths)
    }
}

private struct CircleButton: View {
    let title: String
    let foreground: Color
    let background: Color
    let stroke: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.semibold))
                .foregroundStyle(foreground)
                .frame(width: 80, height: 80)
                .background(background, in: Circle())
                .overlay(Circle().stroke(stroke, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        StopwatchView()
            .navigationTitle("Stopwatch")
            .navigationBarTitleDisplayMode(.inline)
    }
}
