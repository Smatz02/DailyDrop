//
//  PromptManager.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore

// MARK: - Firestore Model for a Daily Prompt
// Each document in the "prompts" collection should map to this structure
struct DailyPrompt: Identifiable, Codable {
    @DocumentID var id: String?    // Firestore doc ID (e.g. "2025-04-23")
    var text: String               // The prompt question (e.g. "What's a song that hypes you up?")
}

// MARK: - Prompt Manager
// This class fetches today's prompt from Firestore and publishes it for use in the app
class PromptManager: ObservableObject {
    @Published var prompt: DailyPrompt?  // The current prompt shown on the home screen

    /// Fetches the prompt from Firestore where the document ID equals today’s date
    func fetchTodayPrompt() {
        let todayID = Self.dateString(from: Date())  // Format: "YYYY-MM-DD"
        print("🕒 Attempting to fetch prompt with ID:", todayID)

        Firestore.firestore()
            .collection("prompts")
            .document(todayID)
            .getDocument { snapshot, error in
                // If the document is found and matches our model, assign it to the prompt
                if let document = try? snapshot?.data(as: DailyPrompt.self) {
                    DispatchQueue.main.async {
                        self.prompt = document
                    }

                } else {
                    // Log the error and use a fallback prompt so the UI doesn’t freeze
                    print("❌ Could not find today's prompt: \(error?.localizedDescription ?? "unknown error")")

                    DispatchQueue.main.async {
                        self.prompt = DailyPrompt(
                            id: "fallback",
                            text: "No prompt found for today. Submit any song you want!",
                        
                        )
                    }
                }
           }
    }
   
    
 


    /// Converts a Date object to a Firestore-friendly document ID string: "yyyy-MM-dd"
     static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}



