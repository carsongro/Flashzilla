//
//  ContentView.swift
//  Flashzilla
//
//  Created by Carson Gross on 7/8/22.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @StateObject var cardCollection = CardCollection()
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var  scenePhase
    @State private var isActive = true
    
    @State private var animationFinished = true
    @State private var showingEditScreen = false
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedData")
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
                
                ZStack {
                    ForEach(0..<cardCollection.cards.count, id: \.self) { index in
                        CardView(card: cardCollection.cards[index]) { correct in
                            withAnimation {
                                removeCard(at: index, correct: correct)
                            }
                        }
                        .stacked(at: index, in: cardCollection.cards.count)
                        .allowsHitTesting(index == cardCollection.cards.count - 1)
                        .accessibilityHidden(index < cardCollection.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0 && animationFinished)
                
                if cardCollection.cards.isEmpty && animationFinished {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        showingEditScreen = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
            
            if differentiateWithoutColor || voiceOverEnabled {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button {
                            withAnimation {
                                removeCard(at: cardCollection.cards.count - 1, correct: false)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Wrong")
                        accessibilityHint("Mark your answer as being incorrect.")
                        
                        Spacer()
                        Button {
                            withAnimation {
                                removeCard(at: cardCollection.cards.count - 1, correct: true)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark your answer as being correct.")
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cardCollection.cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards().environmentObject(cardCollection)
        }
        .onAppear(perform: resetCards)
    }
    
    func removeCard(at index: Int, correct: Bool) {
        guard index >= 0 else { return }
        
        let card = cardCollection.cards.remove(at: index)
        
        if !correct {
            animationFinished = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                cardCollection.cards.insert(card, at: 0)
                animationFinished = true
            }
        }
        
        if cardCollection.cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        cardCollection.loadData()
        timeRemaining = 100
        isActive = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
