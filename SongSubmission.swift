//
//  SongSubmission.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import Foundation
import FirebaseFirestore


// Each song submission = one document in the "submissions" collection
/*struct SongSubmission: Identifiable, Codable {
    // Firestore will auto-generate and manage this ID
    @DocumentID var id: String?

    // The user who submitted (from Firebase Auth)
    var user: String
    var username: String 


    // Basic song info
    var songName: String
    var artist: String

    // Prompt associated with this song (useful for filtering)
    var prompt: String

    // When the song was submitted (used to order feed)
    var timestamp: Date
    
    var spotifyURL: String
    
}
*/

/*
struct SongSubmission: Identifiable, Codable {
    @DocumentID var id: String?
    var user: String
    var username: String // 🔥 Added field
    var profilePictureBase64: String? // 🔥 Added field
    var songName: String
    var artist: String
    var prompt: String
    var timestamp: Date
    var spotifyURL: String
}

*/

struct SongSubmission: Identifiable, Codable {
    @DocumentID var id: String?
    var user: String
    var username: String
    var profilePictureBase64: String?
    var songName: String
    var artist: String
    var prompt: String
    var timestamp: Date
    var spotifyURL: String
}
