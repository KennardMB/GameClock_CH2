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
                    .font(.system(size: 80, weight: .thin))
                    .transition(.opacity) // Smooth swap
            } else {
                // Two-Column Picker
                minSecPicker
                    .frame(height: 200)
            }
            
            // Buttons Row
            HStack(spacing: 40) {
                
                // START BUTTON
                Button(action: startTimer) {
                    Text(isRunning ? "Running" : "Start")
                        .font(.system(size: 16, weight: .bold))
                        .frame(width: 80, height: 80)
                        .background(isRunning || duration == 0 ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(isRunning || duration <= 0)
                
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
                
            }
        }
        .animation(.default, value: isRunning)
    }
    
    private var minSecPicker: some View {
        HStack {
            Picker("Hours", selection: Binding(
                get: { Int(duration)/3600},
                set: { duration = TimeInterval(($0 * 3600) + (Int(duration) % 3600)) }
            )){
                ForEach(0..<24) { Text("\($0) hrs").tag($0) }
            }
            .pickerStyle(.wheel)
            
            Picker("Minutes", selection: Binding(
                get: { (Int(duration) % 3600) / 60 },
                set: {
                    // Divided to get the amount of hours, and then multiplied to have the actual amount of hours
                    let hours = (Int(duration) / 3600) * 3600
                    // Get the remainder (% = modulo) of the seconds
                    let seconds = Int(duration) % 60
                    // Have all the duration (hours, minutes, seconds) to the total duration
                    duration = TimeInterval(hours + ($0 * 60) + seconds)
                }
            )) {
                ForEach(0..<60) { Text("\($0) min").tag($0) }
            }
            .pickerStyle(.wheel)
            
            Picker("Seconds", selection: Binding(
                get: { Int(duration) % 60 },
                set: {
                    let totalWithoutSeconds = (Int(duration) / 60) * 60
                    duration = TimeInterval(totalWithoutSeconds + $0)
                    //It divides by 60 to see how many full minutes exist.
                    //Because it's an Int, it chops off any remaining seconds.
                    //It multiplies by 60 again to get back to a total number of seconds that is perfectly divisible by 60.
                }
            )) {
                ForEach(0..<60) { Text("\($0) sec").tag($0) }
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
        duration = 0
        isRunning = false
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int (seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }
}
#Preview {
    TimerView()
}
