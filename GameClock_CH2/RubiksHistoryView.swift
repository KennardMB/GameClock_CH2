//
//  RubiksHistoryView.swift
//  GameClock_CH2
//
//  Created by Kennard M on 23/04/26.
//
import SwiftData
import SwiftUI
import Foundation

// THE LIST ITSELF
struct SolveListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var solves: [Solve]
    
    // This initializer dynamically filters the Query based on the picker
    init(filterFavorites: Bool) {
        if filterFavorites {
            _solves = Query(filter: #Predicate<Solve> { $0.isFavorite },
                            sort: \Solve.date, order: .reverse)
        } else {
            _solves = Query(sort: \Solve.date, order: .reverse)
        }
    }
    
    var body: some View {
        List {
            if solves.isEmpty {
                ContentUnavailableView("No Solves Found", systemImage: "clock.badge.questionmark")
            }
            else {
                ForEach(solves) { solve in
                    HStack{
                        VStack(alignment: .leading) {
                            Text(solve.formattedTime)
                                .font(.system(.title2))
                                .bold()
                            Text(solve.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { solve.isFavorite.toggle()} label: {
                            Image(systemName: solve.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(.yellow)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete(perform: deleteSolves)
            }
        }
    }
    
    private func deleteSolves(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(solves[index])
        }
    }
}

// THE HISTORY VIEW (INCLUDING FAV)
struct HistorySheetView: View{
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    //default segmented picker (0 = history view, 1 favorites view)
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack{
            VStack {
                Picker("Filter", selection: $selectedTab) {
                    Text("All Solves").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(.segmented)
                .offset(y: 10)
                .padding()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            if selectedTab == 0 {
                SolveListView(filterFavorites: false)
            } else {
                SolveListView(filterFavorites: true)
            }
        }
        .navigationTitle(selectedTab == 0 ? "History" : "Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button("Done") {
                    dismiss()
                }
            }
        }
        
    }
}


#Preview {
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Solve.self, configurations: config)
        
        // Add dummy data to the main context
        let sampleData = [
            Solve(solveTime: 12.45, isFavorite: true),
            Solve(solveTime: 9.99, isFavorite: false),
            Solve(solveTime: 15.20, isFavorite: true)
        ]
        
        for solve in sampleData {
            container.mainContext.insert(solve)
        }
        
        return container
    }() // This () executes the logic and returns the container

    // No 'return' keyword here—just the view!
    HistorySheetView()
        .modelContainer(container)
}
