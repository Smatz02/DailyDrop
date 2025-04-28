//
//  FirebaseManager.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import Foundation
import Firebase
import FirebaseFirestore

// Singleton manager that provides methods to interact with Firestore.
class FirebaseManager {
    static let shared = FirebaseManager()

    // Reference to the Firestore database
    let db = Firestore.firestore()

    // Save a new song submission to Firestore
    func submitSong(_ submission: SongSubmission, completion: @escaping (Error?) -> Void) {
        do {
            // Adds a document to the "submissions" collection using Codable model
            try db.collection("submissions")
                .addDocument(from: submission, completion: completion)
        } catch {
            completion(error)
        }
    }

    // Fetch all song submissions that match a specific prompt
  /*  func fetchSongs(completion: @escaping ([SongSubmission]) -> Void) {
        let db = Firestore.firestore()
        let todayID = PromptManager.dateString(from: Date()) // same date format you use for prompts

        db.collection("submissions")
            .whereField("timestamp", isGreaterThanOrEqualTo: startOfToday())
            .whereField("timestamp", isLessThan: startOfTomorrow())
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    let songs = documents.compactMap { try? $0.data(as: SongSubmission.self) }
                    completion(songs)
                } else {
                    print("❌ Failed to fetch today's songs:", error?.localizedDescription ?? "unknown error")
                    completion([])
                }
            }
    } */
    
    func fetchSongs(for prompt: String, completion: @escaping ([SongSubmission]) -> Void) {
        let db = Firestore.firestore()

        db.collection("submissions")
            .whereField("prompt", isEqualTo: prompt)
            .order(by: "timestamp", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching songs: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let songs: [SongSubmission] = documents.compactMap { doc in
                    try? doc.data(as: SongSubmission.self)
                }
                
                completion(songs)
            }
    }


    // Helper functions
    private func startOfToday() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    private func startOfTomorrow() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfToday())!
    }

}
