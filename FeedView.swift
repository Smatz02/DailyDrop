//
//  FeedView.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//
/*
import SwiftUI

struct FeedView: View {
    // 🔹 Prompt passed from ContentView (e.g. "What's a song that hypes you up?")
    let prompt: String

    // 🔹 State variable to store fetched song submissions
    @State private var songs: [SongSubmission] = []

    // 🔹 Whether the data is still loading
    @State private var isLoading = true

    var body: some View {
        VStack {
            // 🔸 Loading spinner while fetching data
            if isLoading {
                ProgressView("Loading feed...")
                    .padding()
            }

            // 🔸 Message if no songs have been submitted yet
            else if songs.isEmpty {
                Text("No submissions yet for this prompt.")
                    .foregroundColor(.gray)
                    .padding()
            }

            // 🔸 List of submitted songs
            else {
                
                List(songs) { submission in
                    HStack(alignment: .top, spacing: 12) {
                        // 🔥 Profile Picture
                        if let base64String = submission.profilePictureBase64,
                           let imageData = Data(base64Encoded: base64String),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                                .overlay(Text("?").foregroundColor(.white))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(submission.songName.isEmpty ? "Unknown Song" : submission.songName)
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("by \(submission.artist.isEmpty ? "Unknown Artist" : submission.artist)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))

                            Text("Submitted by: \(submission.username.isEmpty ? "Anonymous" : submission.username)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))

                            Text(submission.timestamp, style: .date)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Button(action: {
                                openInSpotify(submission.spotifyURL)
                            }) {
                                Text("Open in Spotify")
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.green.opacity(0.8))
                                    .foregroundColor(.black)
                                    .clipShape(Capsule())
                            }

                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.black) // 🛠 Force dark row background
                   // .background(Color.clear)
                  //  .listRowBackground(Color.clear) // make List rows transparent
                }
                .listStyle(PlainListStyle())
                .background(Color.black)

            }
        }
        .navigationTitle("🎶 Shared Songs")
        
        .onAppear {
            FirebaseManager.shared.fetchSongs(for: prompt) { results in
                self.songs = results
                self.isLoading = false
                
                for song in results {
                    print("Fetched song -> Name: \(song.songName), Artist: \(song.artist), Username: \(song.username)")
                }
            }
        }

        
    }
    
    func openInSpotify(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
*/

import SwiftUI

struct FeedView: View {
    // 🔹 Prompt passed from ContentView (e.g. "What's a song that hypes you up?")
    let prompt: String

    // 🔹 State variable to store fetched song submissions
    @State private var songs: [SongSubmission] = []

    // 🔹 Whether the data is still loading
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Feed...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if songs.isEmpty {
                Text("No submissions yet for this prompt.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(songs) { submission in
                    HStack(alignment: .top, spacing: 12) {
                        // 🔹 Profile Picture
                        if let base64String = submission.profilePictureBase64,
                           let imageData = Data(base64Encoded: base64String),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(Text("?").foregroundColor(.white))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(submission.songName.isEmpty ? "Unknown Song" : submission.songName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("by \(submission.artist.isEmpty ? "Unknown Artist" : submission.artist)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Submitted by: \(submission.username.isEmpty ? "Anonymous" : submission.username)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(submission.timestamp, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color(.systemBackground)) // Light background
                }
                .listStyle(PlainListStyle())
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Shared Songs")
        .background(Color(.systemGroupedBackground))
        .onAppear {
            FirebaseManager.shared.fetchSongs(for: prompt) { results in
                self.songs = results
                self.isLoading = false
                
                for song in results {
                    print("Fetched song -> Name: \(song.songName), Artist: \(song.artist), Username: \(song.username)")
                }
            }
        }
    }
}

