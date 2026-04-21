//
//  RubiksView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftUI

struct RubiksView: View {
    @State var time = 0.0
    @State var isRunning: Bool = false
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Image(systemName: "hand.raised.fingers.spread")
                        .font(.system(size: 100))
                        .frame(width: 550, height: 550)
                }
                .background(.yellow)
                .foregroundStyle(.black)
                .cornerRadius(500)
                
                Spacer()
                
                Button(action: {
                    if isRunning {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }) {
                    Image(systemName: "hand.raised.fingers.spread")
                        .scaleEffect(x: -1, y: 1)
                        .font(.system(size: 100))
                        .frame(width: 550, height: 550)
                }
                .background(.yellow)
                .foregroundStyle(.black)
                .cornerRadius(500)
                .contentShape(Circle())
            }
            .frame(alignment: .leading)
            .overlay(alignment: .center) {
                VStack(spacing: 20) {
                    VStack {
                        Text("Rubiks Timer")
                            .font(.largeTitle)
                        
                        Text(timeFormatter(second: time))
                            .font(.system(size: 64))
                            .monospacedDigit()
                            .padding()
                    }
                }
                .allowsHitTesting(false)
            }
            
            
            VStack {
                Spacer()
            }
            .background(Color.blue.opacity(0.6))
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: {
                        resetTimer()
                    }) {
                        Image(systemName: "info.circle")
                            .resizable(resizingMode: .stretch)
                            .padding(10)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.glass)
                    
                    Button(action: {
                        resetTimer()
                    }) {
                        Image(systemName: "book")
                            .resizable(resizingMode: .stretch)
                            .padding(10)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.glass)
                }
            }
            
        }
        //             .background(Color.black.opacity(0.2))
        //            .allowsHitTesting(false)
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            time += 0.01
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    func resetTimer() {
        stopTimer()
        time = 0.00
    }
    
    func timeFormatter(second: Double) -> String {
        let minutes = Int(second / 60.0)
        let seconds = Int(second.truncatingRemainder(dividingBy: 60.0))
        let tenthsOfASecond = Int(second.truncatingRemainder(dividingBy: 1.0) * 100.0)
        
        return String(format: "%02d.%02d,%02d", minutes, seconds, tenthsOfASecond)
    }
}

#Preview(traits: .landscapeRight) {
    RubiksView()
}
