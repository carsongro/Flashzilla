//
//  EditCards.swift
//  Flashzilla
//
//  Created by Carson Gross on 7/11/22.
//

import SwiftUI

struct EditCards: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cardCollection: CardCollection

    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedData")

    var body: some View {
        NavigationView {
            List {
                Section("Add new card") {
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add card", action: addCard)
                }

                Section {
                    ForEach(0..<cardCollection.cards.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(cardCollection.cards[index].prompt)
                                .font(.headline)
                            Text(cardCollection.cards[index].answer)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: removeCards)
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done)
            }
            .listStyle(.grouped)
            .onAppear(perform: cardCollection.loadData)
        }
    }

    func done() {
        dismiss()
    }

    func addCard() {
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }

        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        cardCollection.cards.insert(card, at: 0)
        newPrompt = ""
        newAnswer = ""
        cardCollection.saveData()
    }

    func removeCards(at offsets: IndexSet) {
        cardCollection.cards.remove(atOffsets: offsets)
        cardCollection.saveData()
    }
}

struct EditCards_Previews: PreviewProvider {
    static var previews: some View {
        EditCards()
    }
}
