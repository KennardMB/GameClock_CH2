//
//  TimerView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI
import UIKit

struct TimerView: View {
    @State private var hours = 0
    @State private var minutes = 5
    @State private var seconds = 0

    @State private var totalDuration: TimeInterval = 0
    @State private var endDate: Date = .now
    @State private var pausedRemaining: TimeInterval = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var didFinish = false

    private var hasTimeSet: Bool { hours + minutes + seconds > 0 }
    private var isActive: Bool { isRunning || isPaused }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            if isActive {
                countdownView
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                pickerView
                    .transition(.opacity)
            }

            Spacer()

            HStack {
                CircleButton(
                    title: "Cancel",
                    foreground: .primary,
                    background: Color(.secondarySystemFill),
                    stroke: Color(.separator)
                ) {
                    cancel()
                }
                .opacity(isActive ? 1 : (hasTimeSet ? 1 : 0.4))
                .disabled(!isActive && !hasTimeSet)

                Spacer()

                CircleButton(
                    title: primaryLabel,
                    foreground: primaryColor,
                    background: primaryColor.opacity(0.2),
                    stroke: primaryColor.opacity(0.5)
                ) {
                    primaryAction()
                }
                .opacity(isActive || hasTimeSet ? 1 : 0.4)
                .disabled(!isActive && !hasTimeSet)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isActive)
    }

    private var primaryLabel: String {
        if isPaused { return "Resume" }
        if isRunning { return "Pause" }
        return "Start"
    }
    private var primaryColor: Color { Palette.timer }

    private var pickerView: some View {
        HStack(spacing: 0) {
            wheel($hours, range: 0..<24, label: "hours")
            wheel($minutes, range: 0..<60, label: "min")
            wheel($seconds, range: 0..<60, label: "sec")
        }
        .frame(height: 220)
        .padding(.horizontal, 16)
    }

    private func wheel(_ binding: Binding<Int>, range: Range<Int>, label: String) -> some View {
        HStack(spacing: 6) {
            Picker(label, selection: binding) {
                ForEach(range, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            Text(label)
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var countdownView: some View {
        TimelineView(.animation(paused: isPaused)) { ctx in
            let remaining = isPaused
                ? pausedRemaining
                : max(0, endDate.timeIntervalSince(ctx.date))
            let progress = totalDuration > 0 ? min(1, remaining / totalDuration) : 0

            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 10)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Palette.timer, Palette.timer.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 6) {
                    Text(format(remaining))
                        .font(.system(size: 58, weight: .thin))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                    if isPaused {
                        Text("Paused")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                }
            }
            .frame(width: 260, height: 260)
            .onChange(of: remaining) { _, newValue in
                if newValue <= 0 && isRunning && !isPaused && !didFinish {
                    finish()
                }
            }
        }
    }

    private func primaryAction() {
        if isPaused { resume() }
        else if isRunning { pause() }
        else { start() }
    }

    private func start() {
        let total = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        guard total > 0 else { return }
        totalDuration = total
        endDate = Date().addingTimeInterval(total)
        isRunning = true
        isPaused = false
        didFinish = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func pause() {
        pausedRemaining = max(0, endDate.timeIntervalSinceNow)
        isPaused = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func resume() {
        endDate = Date().addingTimeInterval(pausedRemaining)
        isPaused = false
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func cancel() {
        isRunning = false
        isPaused = false
        totalDuration = 0
        didFinish = false
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func finish() {
        isRunning = false
        isPaused = false
        didFinish = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func format(_ t: TimeInterval) -> String {
        let total = Int(ceil(t))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
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
        TimerView()
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
    }
}
