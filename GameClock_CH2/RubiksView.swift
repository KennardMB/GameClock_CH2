//
//  RubiksView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 20/04/26.
//

import SwiftData
import SwiftUI

struct RubiksView: View {
    // For Data (modelcontext here means the "warehouse" of the data)
    @Environment(\.modelContext) private var modelContext
    
    // Cases
    enum TimerState {
        case idle, ready, running, finished
    }
    
    // Presses
    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var currentState: TimerState = .idle
    
    // New Stopwatch Variables
    @State private var startTime = Date()
    @State private var finalTime: TimeInterval = 0
    
    
    
    var body: some View {
        ZStack{
            TimelineView(.animation(minimumInterval: 0.01, paused: currentState != .running)) { context in
                
                ZStack {
                    GeometryReader { geometry in
                        HStack(spacing: 170) {
                            // Left Finger
                            SensorView(isPressed: $leftPressed, color: sensorColor)
                                .scaleEffect(x: -1, y: 1)
                            
                            
                            // Right Finger
                            SensorView(isPressed: $rightPressed, color: sensorColor)
                            
                            
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        
                        if currentState == .idle {
                            HStack{
                                Image(systemName: "hand.tap")
                                    .font(.system(size: 50))
                                    .scaleEffect(x:-1, y:1)
                                    .offset(x: -300)
                                    .opacity(0.3)
                                Image(systemName: "hand.tap")
                                    .font(.system(size: 50))
                                    .offset(x: 300)
                                    .opacity(0.3)
                            }
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .allowsHitTesting(false)
                        }

                        
                    }
                    // Center Stopwatch Display
                    VStack(spacing: 20) {
                        let currentDisplayTime = (currentState == .running) ? context.date.timeIntervalSince(startTime) : finalTime
                        // setting condition so we can have animation
                        let condition = currentState == .finished || (currentState == .idle && finalTime > 0)
                        
                        Text(formatTime(currentDisplayTime))
                            .font(.system(
                                size: condition ? 100: 80,
                                weight: condition ? .bold : .light))
                            .monospacedDigit()
                            .foregroundColor(timerTextColor)
                        // if the condition is satisfied then it uses the animation
                            .animation(condition ? .spring(response:0.1, dampingFraction: 0.9) : .none)
                            .frame(width: 800, height: 100)
                        
                        Text(statusMessage)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .allowsHitTesting(false)
                    
                }
            }
            .ignoresSafeArea()
            .onChange(of: leftPressed) { _, _ in updateLogic() }
            .onChange(of: rightPressed) { _, _ in updateLogic() }
            
            // Info and History Button
            GeometryReader { geometry in
                if  (currentState != .running) {
                    HStack {
                        Button(action: {
                            finalTime = 0
                            currentState = .idle
                        }) {
                            Image(systemName: "arrow.trianglehead.counterclockwise")
                                .font(.system(size: 25))
                                .padding(10)
                        }
                        .buttonStyle(.glass)
                        
                        Button(action: {
                            
                        }) {
                            Image(systemName: "book")
                                .font(.system(size: 25))
                                .padding(10)

                        }
                        .buttonStyle(.glass)
                    }
                    .offset(y: geometry.size.height * 0.4)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
            }
            
        }
        .onAppear {
            AppDelegate.orientationLock = .landscapeRight
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                UIApplication.shared.isIdleTimerDisabled = true
            }

        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    // MARK: - Core Logic
    
    private func updateLogic() {
        let bothDown = leftPressed && rightPressed
        let bothUp = !leftPressed && !rightPressed
        
        switch currentState {
        case .idle:
            if bothDown {
                currentState = .ready
                UIImpactFeedbackGenerator(style: .medium)
                    .impactOccurred()
            }
            
        case .ready:
            if !bothDown {
                startTime = Date()
                currentState = .running
            }
            
        case .running:
            if bothDown {
                let recordedTime = Date().timeIntervalSince(startTime)
                finalTime = recordedTime
                currentState = .finished
                // for haptic feedback
                UIImpactFeedbackGenerator(style: .medium)
                    .impactOccurred()
                
                //save to history
                let newSolve = Solve(solveTime: recordedTime)
                        modelContext.insert(newSolve)
            }
            
        case .finished:
            if bothUp {
                currentState = .idle
            }
        }
    }
    
    // MARK: - UI Helpers
    private var statusMessage: String {
        switch currentState {
        case .idle: return "PLACE BOTH INDEX FINGERS"
        case .ready: return "RELEASE TO START"
        case .running: return "TAP BOTH TO STOP"
        case .finished: return "SOLVE COMPLETE"
        }
    }
    
    private var timerTextColor: Color {
        if currentState == .ready { return .yellow }
        if currentState == .finished { return .primary }
        return .primary
    }
    
    private var sensorColor: Color {
        if currentState == .ready { return .green }
        return .yellow
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let hunds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, hunds)
    }
}


struct SensorView: View {
    @Binding var isPressed: Bool
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            let hugeSize = geometry.size.width * 1.4
            
            ZStack{
                Circle()
                    .fill(isPressed ? color : color.opacity(0.15))
                    .frame(width: hugeSize, height: hugeSize)
                    .edgesIgnoringSafeArea(.all)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in if !isPressed { isPressed = true } }
                            .onEnded { _ in isPressed = false }
                    )
                    .animation(.tightUpper, value: isPressed)
                    
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
        
    }
}

extension Animation {
    static let tightUpper = Animation.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.1)
}





#Preview(traits: .landscapeRight) {
    RubiksView()
}
