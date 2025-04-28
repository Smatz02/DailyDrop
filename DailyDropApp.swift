//
//  DailyDropApp.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct DailyDropApp: App {
    init() {
            FirebaseApp.configure() // Initialize Firebase
            signInAnonymouslyIfNeeded()
        }
    
    // This object holds the list of song submissions, shared across the app
    @StateObject private var songStore = SongStore()

    var body: some Scene {
        WindowGroup {
            // Inject songStore into the environment so any view can use it
            HomeView()
                .environmentObject(songStore)
        }
    }
}

// MARK: - Anonymous Auth Helper
func signInAnonymouslyIfNeeded() {
    if Auth.auth().currentUser == nil {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("❌ Auth error: \(error.localizedDescription)")
            } else if let user = result?.user {
                print("✅ Signed in anonymously as \(user.uid)")
            }
        }
    } else {
        print("✅ Already signed in as \(Auth.auth().currentUser?.uid ?? "Unknown")")
    }
}
