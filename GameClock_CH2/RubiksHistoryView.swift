//
//  RubiksHistoryView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 23/04/26.
//
import SwiftData
import SwiftUI



struct SolveListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var solves: [Solve]

    init(showOnlyFavorites: Bool) {
        if showOnlyFavorites {
            _solves = Query(filter: #Predicate<Solve> { $0.isFavorite },
                            sort: \Solve.date, order: .reverse)
        } else {
            _solves = Query(sort: \Solve.date, order: .reverse)
        }
    }

    var body: some View {
//        List {
//            // Ensure NO '$' here
//            ForEach(solves) { solve in
//                HStack {
//                    VStack(alignment: .leading) {
//                        // Ensure NO '$' here
//                        Text(solve.formatTime)
//                            .font(.system(.title3, design: .monospaced))
//                        Text(solve.date.formatted(date: .abbreviated, time: .shortened))
//                            .font(.caption).foregroundStyle(.secondary)
//                    }
//                    Spacer()
//                    Button {
//                        solve.isFavorite.toggle()
//                    } label: {
//                        Image(systemName: solve.isFavorite ? "star.fill" : "star")
//                            .foregroundStyle(.yellow)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .onDelete(perform: deleteItems)
//        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(solves[index])
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let hunds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, hunds)
    }

}

struct HistorySheetView: View{
    @State private var selectedTab = 0
    
    var body: some View {
        
    }
}
#Preview (traits: .landscapeRight) {
    HistorySheetView()
}

