//
//  ContentView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 19/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = "Stopwatch"
    let options = ["Stopwatch", "Timer"]

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Clock Type", selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)  //change the picker to be segmented
                .padding()

                if selection == "Stopwatch" {
                    StopwatchView()
                } else {
                    TimerView()
                }

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Games")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 4)

                    HStack(spacing: 20) {
                        NavigationLink {
                            RubiksView()
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "cube.fill")
                                    .font(.system(size: 44))
                                    .symbolRenderingMode(.hierarchical)
                                Text("Rubik's")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .glassEffect()

                        NavigationLink {
                            ChessView()
                        } label: {
                            VStack(spacing: 10) {
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
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Game Clock")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
