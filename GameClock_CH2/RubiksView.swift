//
//  RubiksView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI
import UIKit

struct RubiksView: View {
    enum TimerState { case idle, ready, running, finished }

    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var currentState: TimerState = .idle
    @State private var startTime = Date()
    @State private var finalTime: TimeInterval = 0
    @State private var showInfo = false
    @State private var celebrate = false
    @State private var didBeatBest = false

    @AppStorage("rubiks.bestTime") private var bestTime: Double = 0

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Palette.ink.ignoresSafeArea()

                TimelineView(.animation(minimumInterval: 0.01, paused: currentState != .running)) { ctx in
                    let elapsed = (currentState == .running)
                        ? ctx.date.timeIntervalSince(startTime)
                        : finalTime

                    ZStack {
                        HStack(spacing: 0) {
                            SensorPad(isPressed: $leftPressed, tint: sensorTint, diameter: geo.size.height * 1.4)
                                .frame(width: geo.size.width * 0.5)
                            SensorPad(isPressed: $rightPressed, tint: sensorTint, diameter: geo.size.height * 1.4)
                                .frame(width: geo.size.width * 0.5)
                        }

                        VStack(spacing: 14) {
                            Text(format(elapsed))
                                .font(.system(size: 108, weight: .bold, design: .monospaced))
                                .foregroundStyle(timerTextColor)
                                .scaleEffect(celebrate ? 1.08 : 1.0)

                            statusChip

                            bottomChip
                                .frame(height: 26)
                        }
                    }
                }
                .onChange(of: leftPressed) { _, _ in update() }
                .onChange(of: rightPressed) { _, _ in update() }

                if currentState != .running {
                    topControls
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showInfo) { infoSheet }
        .onAppear { forceLandscape() }
        .onDisappear { forcePortrait() }
    }

    private var topControls: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Palette.paper)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)

                Spacer()

                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundStyle(Palette.paper)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()
        }
    }

    private var statusChip: some View {
        Text(statusMessage)
            .font(.footnote.weight(.bold))
            .tracking(2)
            .foregroundStyle(statusColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15), in: Capsule())
            .overlay(Capsule().stroke(statusColor.opacity(0.3), lineWidth: 1))
    }

    @ViewBuilder
    private var bottomChip: some View {
        if didBeatBest && currentState == .finished {
            Label("NEW BEST", systemImage: "trophy.fill")
                .font(.footnote.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(Palette.rubiks)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Palette.rubiks.opacity(0.18), in: Capsule())
        } else if bestTime > 0 && (currentState == .idle || currentState == .finished) {
            Text("BEST  \(format(bestTime))")
                .font(.footnote.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(Palette.chalk)
        } else {
            Color.clear
        }
    }

    private var infoSheet: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How it works")
                .font(.title2.bold())

            Label {
                Text("Place both palms on the circular pads.")
            } icon: {
                Image(systemName: "hand.raised.fill").foregroundStyle(Palette.rubiks)
            }
            Label {
                Text("Wait for them to turn teal, then release to start.")
            } icon: {
                Image(systemName: "timer").foregroundStyle(Palette.rubiks)
            }
            Label {
                Text("Tap both pads again when you've solved the cube.")
            } icon: {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.rubiks)
            }

            Button("Got it") { showInfo = false }
                .buttonStyle(.borderedProminent)
                .tint(Palette.rubiks)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .padding(24)
        .presentationDetents([.medium])
    }

    private func update() {
        let bothDown = leftPressed && rightPressed
        let bothUp = !leftPressed && !rightPressed

        switch currentState {
        case .idle:
            if bothDown {
                currentState = .ready
                didBeatBest = false
            }
        case .ready:
            if !bothDown {
                startTime = Date()
                currentState = .running
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        case .running:
            if bothDown {
                finalTime = Date().timeIntervalSince(startTime)
                currentState = .finished
                handleFinish()
            }
        case .finished:
            if bothUp { currentState = .idle }
        }
    }

    private func handleFinish() {
        if bestTime == 0 || finalTime < bestTime {
            bestTime = finalTime
            didBeatBest = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            celebrate = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                celebrate = false
            }
        }
    }

    private var statusMessage: String {
        switch currentState {
        case .idle: return "PLACE BOTH PALMS"
        case .ready: return "RELEASE TO START"
        case .running: return "TAP BOTH TO STOP"
        case .finished: return "SOLVE COMPLETE"
        }
    }

    private var statusColor: Color {
        switch currentState {
        case .ready, .finished: return Palette.rubiks
        default: return Palette.chalk
        }
    }

    private var timerTextColor: Color {
        switch currentState {
        case .ready, .finished: return Palette.rubiks
        case .running: return Palette.paper
        case .idle: return Palette.paper.opacity(0.75)
        }
    }

    private var sensorTint: Color {
        currentState == .ready ? Palette.rubiks : Palette.paper
    }

    private func format(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let hunds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%01d:%02d.%02d", mins, secs, hunds)
    }

    private func forceLandscape() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        }
    }

    private func forcePortrait() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
    }
}

private struct SensorPad: View {
    @Binding var isPressed: Bool
    var tint: Color
    var diameter: CGFloat

    var body: some View {
        Circle()
            .fill(tint.opacity(isPressed ? 1.0 : 0.18))
            .frame(width: diameter)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !isPressed { isPressed = true } }
                    .onEnded { _ in isPressed = false }
            )
            .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1), value: isPressed)
    }
}

#Preview(traits: .landscapeRight) {
    RubiksView()
}
