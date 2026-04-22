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

                VStack (spacing: 20) {
                    NavigationLink("Rubik's") {
                        RubiksView()
                    }
                    .buttonStyle(.bordered)
                    .glassEffect()

                    NavigationLink("Chess") {
                        ChessView()
                    }
                    .buttonStyle(.bordered)
                    .glassEffect()

                    Button("Soon...") { }
                        .buttonStyle(.bordered)
                        .disabled(true)
                        .glassEffect()

                    Button("Soon...") { }
                        .buttonStyle(.bordered)
                        .disabled(true)
                    
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    ContentView()
}
