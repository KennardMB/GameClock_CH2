//
//  ChessView.swift
//  GameClock_CH2
//
//  Created by Asadullokh on 20/04/26.
//

import SwiftUI

struct ChessView: View {
    @State var leftTime = 300.0
    @State var rightTime = 300.0
    @State var startTime = 300.0 // selected preset, used on reset
    @State var increment = 0.0

    @State var leftMoves = 0
    @State var rightMoves = 0

    @State var isRunning = false
    @State var hasStarted = false // First time after reset
    @State var leftIsActive = false
    @State var timer: Timer?

    @State var isButtonsExpanded: Bool = false

    let timeOptions: [(String, Double)] = [
        ("1 min", 60.0),
        ("3 min", 180.0),
        ("5 min", 300.0),
        ("10 min", 600.0),
        ("15 min", 900.0),
        ("30 min", 1800.0)
    ]

    let incrementOptions: [(String, Double)] = [
        ("+0", 0.0),
        ("+2s", 2.0),
        ("+5s", 5.0),
        ("+10s", 10.0)
    ]

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Button(action: {
                    if isRunning && leftIsActive {
                        leftTime += increment
                        leftMoves += 1
                        leftIsActive = false
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(timeFormatter(second: leftTime))
                            .font(.system(size: 96))
                            .monospacedDigit()
                            .foregroundStyle(.black)
                        if hasStarted {
                            Text("\(leftMoves) moves")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && leftIsActive ? .white : .gray.opacity(0.3))

                Button(action: {
                    if isRunning && !leftIsActive {
                        rightTime += increment
                        rightMoves += 1
                        leftIsActive = true
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(timeFormatter(second: rightTime))
                            .font(.system(size: 96))
                            .monospacedDigit()
                            .foregroundStyle(.black)
                        if hasStarted {
                            Text("\(rightMoves) moves")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && !leftIsActive ? .white : .gray.opacity(0.3))
            }
            .clipShape(RoundedRectangle(cornerRadius: 40))

            // hide the clock halves while picking presets
            if !hasStarted {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()
            }

            GlassEffectContainer(spacing: 30) {
                VStack(spacing: 16) {
                    if !hasStarted {
                        HStack(spacing: 6) {
                            ForEach(timeOptions, id: \.0) { option in
                                Button(action: {
                                    startTime = option.1
                                    leftTime = option.1
                                    rightTime = option.1
                                }) {
                                    Text(option.0)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(startTime == option.1 ? .blue : .gray)
                            }
                        }

                        HStack(spacing: 6) {
                            ForEach(incrementOptions, id: \.0) { option in
                                Button(action: {
                                    increment = option.1
                                }) {
                                    Text(option.0)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(increment == option.1 ? .blue : .gray)
                            }
                        }
                    }

                    if isButtonsExpanded {
                        Button(action: {
                            withAnimation{
                                resetTimer()
                                isButtonsExpanded = false
                            }
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 30))
                                .frame(width: 60, height: 60)
                        }
                        .buttonStyle(.glass)
                        .tint(.red)
                    }

                    Button(action: {
                        withAnimation{
                            if isRunning {
                                stopTimer()
                                isButtonsExpanded = true
                            } else {
                                startTimer()
                                isButtonsExpanded = false
                            }
                        }
                    }) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.glass)
                    .tint(!hasStarted ? .white : (isRunning ? .red : .black.opacity(0.1)))
                }
            }
        }
        .background(.black.opacity(0.45))
        .onAppear {
            AppDelegate.orientationLock = .landscapeRight
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
            }
        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }

    func startTimer() {
        isRunning = true
        hasStarted = true
        leftIsActive = true
        leftMoves = 0
        rightMoves = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if leftIsActive {
                leftTime -= 0.01
            } else {
                rightTime -= 0.01
            }
        }
    }

    func stopTimer() {
        isRunning = false
        timer?.invalidate()
    }

    func resetTimer() {
        stopTimer()
        leftTime = startTime
        rightTime = startTime
        leftIsActive = false
        hasStarted = false
        leftMoves = 0
        rightMoves = 0
    }

    func timeFormatter(second: Double) -> String {
        let minutes = Int(second / 60.0)
        let seconds = Int(second.truncatingRemainder(dividingBy: 60.0))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview(traits: .landscapeRight) {
    ChessView()
}
