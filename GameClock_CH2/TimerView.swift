//
//  TimerView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI

struct TimerView: View {
    @State private var duration: TimeInterval = 0
    @State private var isRunning = false
    @State private var timer: Timer? = nil
    var minutes: Int { Int(duration) / 60 }
    var seconds: Int { Int(duration) % 60 }
    
    var body: some View {
            VStack(spacing: 40) {
                if isRunning {
                    // Large Countdown Text
                    Text(formatTime(duration))
                        .font(.system(size: 80, weight: .thin, design: .monospaced))
                        .transition(.opacity) // Smooth swap
                } else {
                    // Two-Column Picker
                    minSecPicker
                        .frame(height: 200)
                }
                
                // Buttons Row
                HStack(spacing: 40) {
                    // STOP / RESET BUTTON
                    Button(action: stopTimer) {
                        Text("Stop")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 80, height: 80)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .opacity(duration == 0 ? 0.5 : 1.0)
                    }
                    .disabled(duration == 0)

                    // START BUTTON
                    Button(action: startTimer) {
                        Text(isRunning ? "Running" : "Start")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 80, height: 80)
                            .background(isRunning ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .disabled(isRunning || duration <= 0)
                }
            }
            .animation(.default, value: isRunning)
        }
    
    private var minSecPicker: some View {
            HStack {
                Picker("Minutes", selection: Binding(
                    get: { Int(duration) / 60 },
                    set: { duration = TimeInterval(($0 * 60) + (Int(duration) % 60)) }
                )) {
                    ForEach(0..<60) { Text("\($0) m").tag($0) }
                }
                .pickerStyle(.wheel)
                
                Picker("Seconds", selection: Binding(
                    get: { Int(duration) % 60 },
                    set: { duration = TimeInterval(((Int(duration) / 60) * 60) + $0) }
                )) {
                    ForEach(0..<60) { Text("\($0) s").tag($0) }
                }
                .pickerStyle(.wheel)
            }
        }
    
    // LOGIC
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if duration > 0 {
                duration -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        isRunning = false
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
#Preview {
    TimerView()
}
