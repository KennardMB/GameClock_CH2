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
    @State var hasStarted = false // First time after reset
    @State var leftIsActive = false
    @State var timer: Timer?
    
    @State var isButtonsExpanded: Bool = false
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Button(action: {
                    if isRunning && leftIsActive {
                        leftIsActive = false
                    }
                }) {
                    Text(timeFormatter(second: leftTime))
                        .font(.system(size: 96))
                        .monospacedDigit()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && leftIsActive ? .white : .gray.opacity(0.3))
                
                Button(action: {
                    if isRunning && !leftIsActive {
                        leftIsActive = true
                    }
                }) {
                    Text(timeFormatter(second: rightTime))
                        .font(.system(size: 96))
                        .monospacedDigit()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(isRunning && !leftIsActive ? .white : .gray.opacity(0.3))
            }
            .clipShape(RoundedRectangle(cornerRadius: 40))
            
            
            GlassEffectContainer(spacing: 70) {
                VStack(spacing: 70) {
                    if isButtonsExpanded {
                        Button(action: {
                            resetTimer()
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
                    .tint(isRunning ? .red : .black.opacity(0.1))
                }
            }
        }
        .background(.black.opacity(0.45))
        .onAppear {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
            }
        }
        .onDisappear {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
    
    func startTimer() {
        isRunning = true
        hasStarted = true
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
        hasStarted = false
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
