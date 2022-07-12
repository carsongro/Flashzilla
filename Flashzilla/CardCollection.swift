//
//  CardCollection.swift
//  Flashzilla
//
//  Created by Carson Gross on 7/11/22.
//

import Foundation

class CardCollection: ObservableObject {
    @Published var cards = [Card]()
    
    init() {
        do {
            let data = try Data(contentsOf: savePath)
            cards = try JSONDecoder().decode([Card].self, from: data)
        } catch {
            cards = []
        }
    }
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedData")

        func loadData() {
            
        do {
            let data = try Data(contentsOf: savePath)
            cards = try JSONDecoder().decode([Card].self, from: data)
        } catch {
            cards = []
        }
        
    }
    
    func saveData() {
        
        do {
            let data = try JSONEncoder().encode(cards)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
    }
}
