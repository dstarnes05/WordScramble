//
//  ContentView.swift
//  WordScramble
//
//  Created by Daniel Starnes on 1/16/26.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        
        NavigationStack {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(.brown)
                .navigationTitle(rootWord)
                .toolbar {
                    Button("Start Over", action: startGame)
                        .foregroundStyle(Color.black)
                }
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage)
                }
                
                Text("Current Score: \(score)")
                    .font(.headline.bold())
            }
    }

    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isUnique(word: answer) else {
            wordError(title: "Word not unique", message: "You really thought you could use the root word as an answer?")
            return
        }
        
        guard tooShort(word: answer) else {
            wordError(title: "Word is too short", message: "Valid words must be longer than 3 letters.")
            return
        }
        
        
        withAnimation(.bouncy(duration: Double(answer.count))) {
            usedWords.insert(answer, at: 0)
        }

        score += answer.count
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                score = 0
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func tooShort(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    
    func isUnique(word: String) -> Bool {
        if word == rootWord {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
