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
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ContentView()
}
