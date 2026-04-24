//
//  RubiksHistoryView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 23/04/26.
//

import SwiftData
import SwiftUI

@Model
class RubiksResult: Identifiable {
    
    var id = UUID()
    var rubiksTime: Double
    var date: Date
    
    init(rubiksTime: Double, date: Date, id: UUID = UUID()) {
        self.id = id
        self.rubiksTime = rubiksTime
        self.date = date
    }
}

struct RubiksHistoryView: View{
    var body: some View {
        
    }
}
#Preview (traits: .landscapeRight) {
    RubiksHistoryView()
}

