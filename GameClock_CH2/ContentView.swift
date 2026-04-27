//
//  ContentView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 19/04/26.
//
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selection = "Stopwatch"
    let options = ["Stopwatch", "Timer"]

    var body: some View {
        NavigationStack {
                VStack(spacing: 50) {
                    Picker("Clock Type", selection: $selection) {
                        ForEach(options, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)  //change the picker to be segmented
                    .padding()

                    Group {
                        if selection == "Stopwatch" {
                            StopwatchView()
                        } else {
                            TimerView()
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Games")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 4)

                        NavigationLink {
                            RubiksView()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "cube.fill")
                                    .font(.system(size: 44))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Rubik's")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .padding(18)
                        }
                        .buttonStyle(.bordered)
                        .tint(.yellow)
                        .glassEffect()

                        NavigationLink {
                            ChessView()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 44))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Chess")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                        .glassEffect()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, alignment: .top)
            
            .navigationTitle("Game Clock")
            .navigationBarTitleDisplayMode(.inline)
        }
        .modelContainer(for: Solve.self)
        .onAppear {
            AppDelegate.orientationLock = .portrait
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
}

#Preview {
    ContentView()
}
