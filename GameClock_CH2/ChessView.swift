//
//  ChessView.swift
//  GameClock_CH2
//
//  Created by Asadullokh on 20/04/26.
//

import SwiftUI
import UIKit

struct ChessView: View {
    enum Side { case left, right }

    @State private var leftTime: TimeInterval = 300
    @State private var rightTime: TimeInterval = 300
    @State private var baseTime: TimeInterval = 300
    @State private var increment: TimeInterval = 0

    @State private var leftMoves = 0
    @State private var rightMoves = 0

    @State private var isRunning = false
    @State private var hasStarted = false
    @State private var leftIsActive = true
    @State private var timer: Timer?
    @State private var isButtonsExpanded = false
    @State private var loser: Side?

    @Environment(\.dismiss) private var dismiss

    private let presets: [(String, TimeInterval)] = [
        ("1 min", 60),
        ("3 min", 180),
        ("5 min", 300),
        ("10 min", 600),
        ("15 min", 900),
        ("30 min", 1800)
    ]

    private let increments: [(String, TimeInterval)] = [
        ("No bonus", 0),
        ("+2s", 2),
        ("+5s", 5),
        ("+10s", 10)
    ]

    var body: some View {
        ZStack {
            Palette.ink.ignoresSafeArea()

            HStack(spacing: 0) {
                clockHalf(side: .left, time: leftTime, moves: leftMoves)
                clockHalf(side: .right, time: rightTime, moves: rightMoves)
            }
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .padding(10)

            if loser != nil {
                gameOverOverlay
            } else if !hasStarted {
                setupOverlay
            } else {
                controlCluster
            }

            if hasStarted && !isRunning && loser == nil {
                pausedBadge
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            backButton
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { forceLandscape() }
        .onDisappear {
            timer?.invalidate()
            forcePortrait()
        }
    }

    // MARK: - Halves

    private func clockHalf(side: Side, time: TimeInterval, moves: Int) -> some View {
        let isActive = isRunning && ((side == .left) == leftIsActive)
        let isLow = time <= 10 && isRunning && isActive
        let panelBg = bgColor(active: isActive, low: isLow)
        let text = textColor(active: isActive, low: isLow)

        return Button {
            handleTap(side: side)
        } label: {
            VStack(spacing: 10) {
                Text(format(time))
                    .font(.system(size: 96, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(text)
                if hasStarted {
                    Text("\(moves) moves")
                        .font(.caption.weight(.semibold))
                        .tracking(1.2)
                        .foregroundStyle(text.opacity(0.55))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(panelBg)
        .overlay(alignment: .bottom) {
            if isActive && !isLow {
                Capsule()
                    .fill(Palette.chess)
                    .frame(width: 72, height: 4)
                    .padding(.bottom, 22)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.2), value: isLow)
    }

    private func bgColor(active: Bool, low: Bool) -> Color {
        if low { return Color.red.opacity(0.85) }
        if active { return Palette.paper }
        return Palette.smoke
    }

    private func textColor(active: Bool, low: Bool) -> Color {
        if low { return .white }
        if active { return .black }
        return Palette.chalk
    }

    // MARK: - Overlays

    private var controlCluster: some View {
        GlassEffectContainer(spacing: 24) {
            VStack(spacing: 24) {
                if isButtonsExpanded {
                    Button {
                        withAnimation { resetAll() }
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 24))
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.glass)
                    .tint(.red)
                }

                Button {
                    withAnimation {
                        if isRunning {
                            pauseTimer()
                            isButtonsExpanded = true
                        } else {
                            resumeTimer()
                            isButtonsExpanded = false
                        }
                    }
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glass)
                .tint(isRunning ? .red : Palette.chess)
            }
        }
    }

    private var setupOverlay: some View {
        VStack(spacing: 18) {
            Image(systemName: "crown.fill")
                .font(.system(size: 32))
                .foregroundStyle(Palette.chess)

            Text("Chess Clock")
                .font(.title.weight(.bold))
                .foregroundStyle(Palette.paper)

            VStack(spacing: 10) {
                Text("GAME LENGTH")
                    .font(.caption.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(Palette.chalk)
                HStack(spacing: 8) {
                    ForEach(presets, id: \.0) { preset in
                        chip(label: preset.0, isSelected: baseTime == preset.1) {
                            baseTime = preset.1
                            leftTime = preset.1
                            rightTime = preset.1
                        }
                    }
                }
            }

            VStack(spacing: 10) {
                Text("INCREMENT PER MOVE")
                    .font(.caption.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(Palette.chalk)
                HStack(spacing: 8) {
                    ForEach(increments, id: \.0) { inc in
                        chip(label: inc.0, isSelected: increment == inc.1) {
                            increment = inc.1
                        }
                    }
                }
            }

            Text("Tap the active clock to pass turn.")
                .font(.footnote)
                .foregroundStyle(Palette.chalk)

            Button {
                withAnimation { startTimer() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Palette.chess, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(28)
        .frame(maxWidth: 560)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Palette.smoke, lineWidth: 1)
        )
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Palette.paper)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Palette.chess : Palette.smoke, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var gameOverOverlay: some View {
        let winnerText = (loser == .left) ? "Right wins" : "Left wins"
        return VStack(spacing: 14) {
            Image(systemName: "crown.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Palette.chess)
            Text("Time's up")
                .font(.title.weight(.bold))
                .foregroundStyle(Palette.paper)
            Text(winnerText)
                .font(.title3)
                .foregroundStyle(Palette.chalk)

            Button {
                withAnimation { resetAll() }
            } label: {
                Text("Play Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Palette.chess, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 6)
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var pausedBadge: some View {
        Label("PAUSED", systemImage: "pause.fill")
            .font(.footnote.weight(.bold))
            .tracking(2)
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Palette.smoke, in: Capsule())
            .overlay(Capsule().stroke(Palette.paper.opacity(0.2), lineWidth: 1))
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .top)
    }

    private var backButton: some View {
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
            }
            .padding(.leading, 24)
            .padding(.top, 20)

            Spacer()
        }
    }

    // MARK: - Logic

    private func handleTap(side: Side) {
        guard isRunning else { return }
        if side == .left && leftIsActive {
            leftTime += increment
            leftMoves += 1
            leftIsActive = false
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else if side == .right && !leftIsActive {
            rightTime += increment
            rightMoves += 1
            leftIsActive = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func startTimer() {
        isRunning = true
        hasStarted = true
        leftIsActive = true
        isButtonsExpanded = false
        leftMoves = 0
        rightMoves = 0
        scheduleTick()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func resumeTimer() {
        isRunning = true
        scheduleTick()
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }

    private func resetAll() {
        timer?.invalidate()
        isRunning = false
        hasStarted = false
        isButtonsExpanded = false
        leftIsActive = true
        leftTime = baseTime
        rightTime = baseTime
        leftMoves = 0
        rightMoves = 0
        loser = nil
    }

    private func scheduleTick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let step = 0.05
            if leftIsActive {
                leftTime = max(0, leftTime - step)
                if leftTime == 0 { handleLoss(.left) }
            } else {
                rightTime = max(0, rightTime - step)
                if rightTime == 0 { handleLoss(.right) }
            }
        }
    }

    private func handleLoss(_ side: Side) {
        timer?.invalidate()
        isRunning = false
        loser = side
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func format(_ t: TimeInterval) -> String {
        if t < 10 {
            let whole = Int(t)
            let tenths = Int((t * 10).truncatingRemainder(dividingBy: 10))
            return String(format: "%d.%d", whole, tenths)
        }
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
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

#Preview(traits: .landscapeRight) {
    ChessView()
}
