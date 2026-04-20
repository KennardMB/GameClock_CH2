//
//  ChessView.swift
//  GameClock_CH2
//
//  Created by Asadullokh on 20/04/26.
//

import SwiftUI

struct ChessView: View {
    @State var leftTime = 3600.0
    @State var rightTime = 3600.0
    @State var isRunning = false
    @State var leftIsActive = false
    @State var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Button(action: {
                    if isRunning && leftIsActive {
                        leftIsActive = false
                    }
                }) {
                    Text(timeFormatter(second: leftTime))
                        .font(.system(size: 64))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && leftIsActive ? .white : .gray.opacity(0.3))
                .foregroundStyle(.black)
                .cornerRadius(20)

                Button(action: {
                    if isRunning && !leftIsActive {
                        leftIsActive = true
                    }
                }) {
                    Text(timeFormatter(second: rightTime))
                        .font(.system(size: 64))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && !leftIsActive ? .white : .gray.opacity(0.3))
                .foregroundStyle(.black)
                .cornerRadius(20)
            }

            HStack {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    }
                    else {
                        startTimer()
                    }
                }) {
                    Image(systemName: isRunning ? "pause" : "play.fill")
                }
                .padding()
                .background(isRunning ? .red : .green)
                .foregroundStyle(.white)
                .cornerRadius(10)

                Button(action: {
                    resetTimer()
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }

    func startTimer() {
        isRunning = true
        leftIsActive = true
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
        leftTime = 3600.0
        rightTime = 3600.0
        leftIsActive = false
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
