//
//  Stopwatch.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI

struct StopWatch: View{
    @State var time = 0.0
    @State var isRunning: Bool = false
    @State var timer: Timer?
    
    var body: some View{
        VStack (){
//            Text(String(format:"%.2f", time))
            Text(timeFormatter(second: time))
                .font(.system(size: 64))
                .monospacedDigit()
                .padding()
            
            HStack {
                Button (action: {
                    if isRunning {
                        stopTimer()
                    }
                    else {
                        startTimer ()
                    }
                }) {
                    Image (systemName: isRunning ? "pause" : "play.fill")
                }
                .padding()
                .background(isRunning ? .red : .green)
                .foregroundStyle(.white)
                .cornerRadius(10)
                
                Button (action: {
                    resetTimer ()
                }) {
                    Image (systemName: "arrow.trianglehead.counterclockwise")
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
    }
    
    func startTimer () {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true)
        { _ in
            time += 0.01
        }
    }
    
    func stopTimer () {
        isRunning = false
        timer?.invalidate()
    }
    
    func resetTimer () {
        stopTimer()
        time = 0.00
    }
    
    func timeFormatter (second: Double) -> String {
        let minutes = Int(second / 60.0)
        let seconds = Int(second.truncatingRemainder(dividingBy: 60.0))
        let tenthsOfASecond = Int(second.truncatingRemainder(dividingBy: 1.0) * 100.0)
        
        return String(format: "%02d.%02d,%02d", Int(exactly: minutes)!, Int(exactly: seconds)!, Int(exactly: tenthsOfASecond)!)
    }
}

#Preview {
    StopWatch()
}
