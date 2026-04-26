//
//  StopwatchView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI

struct StopwatchView: View {
    
    @State private var startTime = Date()
    @State private var finalTime: TimeInterval = 0
    @State private var displayTime: String = "00.00,00"
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    
    @State var time = 0.0
   
    
    var body: some View {
        VStack {
            Text(displayTime)
                .multilineTextAlignment(.center)
                .monospacedDigit()
                .font(.system(size: 80))
                .fontWeight(.thin)
                .frame(height: 200)
                .padding()
            
            HStack (spacing: 100){
                Button(action: {
                    if isRunning {
                        pause()
                    } else {
                        start()
                    }
                }) {
                    Image(systemName: isRunning ? "pause" : "play.fill")
                }
                .font(.system(size: 24, weight: .bold))
                .frame(width: 100, height: 100)
                .background(isRunning ? .red : .green)
                .foregroundStyle(.white)
                .clipShape(Circle())
                
                Button(action: {
                    reset()
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                }
                .font(.system(size: 24, weight: .bold))
                .frame(width: 100, height: 100)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(Circle())
            }
        }
    }
    
    func start() {
            startTime = Date()
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                formatTime()
            }
        }

        func pause() {
            finalTime += Date().timeIntervalSince(startTime)
            timer?.invalidate()
            isRunning = false
        }

        func reset() {
            timer?.invalidate()
            finalTime = 0
            isRunning = false
            formatTime()
        }

        func formatTime() {
            let totalElapsed = isRunning ? finalTime + Date().timeIntervalSince(startTime) : finalTime
            
            let minutes = Int(totalElapsed) / 60
            let seconds = Int(totalElapsed) % 60
            let tenths = Int((totalElapsed * 100).truncatingRemainder(dividingBy: 100))
            
            displayTime = String(format: "%02d.%02d,%02d", minutes, seconds, tenths)
        }

}


#Preview {
    StopwatchView()
}
