import SwiftUI

struct CubeTimerView: View {
    enum TimerState {
        case idle, ready, running, finished
    }
    
    @State private var leftPressed = false
    @State private var rightPressed = false
    @State private var currentState: TimerState = .idle
    
    @State private var startTime = Date()
    @State private var finalTime: TimeInterval = 0

    var body: some View {
//        TimelineView(.animation(minimumInterval: 0.01, paused: currentState != .running)) { context in
//            HStack(spacing: 0) {
//                // Left Sensor
//                SensorView(isPressed: $leftPressed, color: sensorColor)
//                
//                // Center Display
//                VStack(spacing: 20) {
//                    let currentDisplayTime = (currentState == .running) ? context.date.timeIntervalSince(startTime) : finalTime
//                    
//                    Text(formatTime(currentDisplayTime))
//                        .font(.system(size: 80, weight: .bold, design: .monospaced))
//                        .foregroundColor(timerTextColor)
//                    
//                    Text(statusMessage)
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color(UIColor.systemBackground))
//                
//                // Right Sensor
//                SensorView(isPressed: $rightPressed, color: sensorColor)
//            }
//        }
//        .ignoresSafeArea()
//        .onChange(of: leftPressed) { _, _ in updateLogic() }
//        .onChange(of: rightPressed) { _, _ in updateLogic() }
    }

    // MARK: - Core Logic
    
    private func updateLogic() {
        let bothDown = leftPressed && rightPressed
        let bothUp = !leftPressed && !rightPressed
        
        switch currentState {
        case .idle:
            if bothDown {
                currentState = .ready
            }
            
        case .ready:
            if !bothDown {
                // Step 3: One or both hands taken off -> Start instantly
                startTime = Date()
                currentState = .running
            }
            
        case .running:
            if bothDown {
                // Step 4: Both hands on buttons -> Stop
                finalTime = Date().timeIntervalSince(startTime)
                currentState = .finished
            }
            
        case .finished:
            // Step 5: After stopping, wait until both hands are removed
            // before allowing the next "Ready" state.
            if bothUp {
                currentState = .idle
            }
        }
    }

    // MARK: - UI Helpers
    
    private var statusMessage: String {
        switch currentState {
        case .idle: return "PLACE BOTH PALMS"
        case .ready: return "RELEASE TO START"
        case .running: return "TAP BOTH TO STOP"
        case .finished: return "SOLVE COMPLETE"
        }
    }
    
    private var timerTextColor: Color {
        if currentState == .ready { return .green }
        if currentState == .finished { return .yellow }
        return .primary
    }
    
    private var sensorColor: Color {
        if currentState == .ready { return .green }
        return .blue
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let hunds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%01d:%02d.%02d", mins, secs, hunds)
    }
}
//
//// Custom Sensor remains the same for instant touch detection
//struct SensorView: View {
//    @Binding var isPressed: Bool
//    var color: Color
//
//    var body: some View {
//        Rectangle()
//            .fill(isPressed ? color : color.opacity(0.15))
//            .frame(width: 120)
//            .gesture(
//                DragGesture(minimumDistance: 0)
//                    .onChanged { _ in if !isPressed { isPressed = true } }
//                    .onEnded { _ in isPressed = false }
//            )
//            .animation(.tightUpper, value: isPressed)
//    }
//}
//
//extension Animation {
//    static let tightUpper = Animation.interactiveSpring(response: 0.5 /*, dampingFraction: 0.8, blendDuration: 0.1*/)
//}
//
//
//struct CubeTimerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CubeTimerView()
//            .previewInterfaceOrientation(.landscapeLeft)
//    }
//}
