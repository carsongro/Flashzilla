//
//  ContentView-ViewModel.swift
//  Flashzilla
//
//  Created by Carson Gross on 7/11/22.
//

import Foundation

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var cards = [Card]()
        
        @Published var timeRemaining = 100
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        @Published var isActive = true
        
        @Published var animationFinished = true
        @Published var showingEditScreen = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        func loadData() {
    //        if let data = UserDefaults.standard.data(forKey: "Cards") {
    //            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
    //                cards = decoded
    //            }
    //        }

            do {
                let data = try Data(contentsOf: savePath)
                cards = try JSONDecoder().decode([Card].self, from: data)
            } catch {
                cards = []
            }

        }
        
        func removeCard(at index: Int, correct: Bool) {
            guard index >= 0 else { return }
            
            let card = cards.remove(at: index)
            
            if !correct {
                animationFinished = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.cards.insert(card, at: 0)
                    self.animationFinished = true
                }
            }
            
            if cards.isEmpty {
                isActive = false
            }
        }
        
        func resetCards() {
            loadData()
            timeRemaining = 100
            isActive = true
        }
    }
}
