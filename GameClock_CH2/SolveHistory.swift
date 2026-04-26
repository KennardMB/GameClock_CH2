//
//  SolveHistory.swift
//  GameClock_CH2
//
//  Created by Kennard M on 27/04/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Solve: Identifiable {
    
    var id = UUID()
    var solveTime: TimeInterval
    var date: Date
    var isFavorite: Bool
    
    init(solveTime: TimeInterval, date: Date = .now, isFavorite: Bool = false, id: UUID = UUID()) {
        self.id = id
        self.solveTime = solveTime
        self.isFavorite = isFavorite
        self.date = date
    }
    
    var formattedTime: String {
            let mins = Int(solveTime) / 60
            let secs = Int(solveTime) % 60
            let hunds = Int((solveTime.truncatingRemainder(dividingBy: 1)) * 100)
            return String(format: "%02d.%02d,%02d", mins, secs, hunds)
        }
}
