//
//  SubmitSongView.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//
import SwiftUI
import FirebaseAuth

struct SubmitSongView: View {
    // The prompt that the user is responding to
    let prompt: String

    // Local state for the song and artist input fields
    @State private var songName: String = ""
    @State private var artist: String = ""
    @State private var spotifyURL: String = ""


    // Used to dismiss this view after submission
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
                Text("Submit for:")
                    .font(.headline)

                Text("“\(prompt)”")
                    .italic()
                    .multilineTextAlignment(.center)

                // Paste Spotify URL
                TextField("Paste Spotify track link", text: $spotifyURL)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .keyboardType(.URL)

                // Load from Link button
                Button("Load from Link") {
                    loadTrackDetails(from: spotifyURL)
                }
                .buttonStyle(.bordered)

                // Show loaded song details, if any
                if !songName.isEmpty && !artist.isEmpty {
                    VStack(alignment: .leading) {
                        Text("🎵 \(songName)")
                            .font(.headline)
                        Text("👤 \(artist)")
                            .foregroundColor(.secondary)
                    }
                }

                // Submit button only enabled once track is loaded
                Button("Submit") {
                    let username = UserDefaults.standard.string(forKey: "username") ?? "Anonymous"
                        let profilePictureBase64 = UserDefaults.standard.string(forKey: "profilePictureBase64")

                        let newSubmission = SongSubmission(
                            user: Auth.auth().currentUser?.uid ?? "unknown",
                            username: username, // 🔥 New
                            profilePictureBase64: profilePictureBase64, // 🔥 New
                            songName: songName,
                            artist: artist,
                            prompt: prompt,
                            timestamp: Date(),
                            spotifyURL: spotifyURL
                        )

                        FirebaseManager.shared.submitSong(newSubmission) { error in
                            if let error = error {
                                print("❌ Error submitting song: \(error)")
                            } else {
                                print("✅ Song submitted to Firestore!")
                                songName = ""
                                artist = ""
                                spotifyURL = ""
                                dismiss()
                            }
                        }
                }
                .disabled(songName.isEmpty || artist.isEmpty)
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Submit a Song")
        }
    
    func loadTrackDetails(from url: String) {
        guard let trackID = extractSpotifyTrackID(from: url) else {
            print("❌ Invalid Spotify URL")
            return
        }

        getSpotifyAccessToken { token in
            guard let token = token else {
                print("❌ Failed to get Spotify token")
                return
            }

            let trackURL = URL(string: "https://api.spotify.com/v1/tracks/\(trackID)")!
            var request = URLRequest(url: trackURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let name = json["name"] as? String,
                   let artists = json["artists"] as? [[String: Any]],
                   let artistName = artists.first?["name"] as? String {
                    DispatchQueue.main.async {
                        self.songName = name
                        self.artist = artistName
                        print("✅ Loaded track: \(name) by \(artistName)")
                    }
                } else {
                    print("❌ Failed to load track info")
                }
            }.resume()
        }
    }

    func extractSpotifyTrackID(from url: String) -> String? {
        // Extract ID from either spotify:track:ID or https://open.spotify.com/track/ID
        if let range = url.range(of: "track/") {
            let idStart = url[range.upperBound...]
            return idStart.split(separator: "?").first.map(String.init)
        } else if url.starts(with: "spotify:track:") {
            return url.replacingOccurrences(of: "spotify:track:", with: "")
        }
        return nil
    }

    func getSpotifyAccessToken(completion: @escaping (String?) -> Void) {
        let clientID = "2c33f4ee325d4d0db218f9f0c3685a45"
        let clientSecret = "67b8c88cb5ab49688401fced39de479a"
        let credentials = "\(clientID):\(clientSecret)"
        let encoded = Data(credentials.utf8).base64EncodedString()

        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Token request error:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse token response")
                completion(nil)
                return
            }

            if let token = json["access_token"] as? String {
                print("✅ Got Spotify token: \(token.prefix(10))...")
                completion(token)
            } else {
                print("❌ Token not found in response:", json)
                completion(nil)
            }
        }.resume()
    }


}

