//
//  ContentView.swift
//  DailyDrop
//
//  Created by Qasim Zaidi on 4/22/25.
//

import SwiftUI

struct ContentView: View {
    // Create and observe the prompt manager
    @StateObject private var promptManager = PromptManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🎧 Daily Prompt")
                    .font(.title)
                    .bold()

                if let prompt = promptManager.prompt {
                    // If a prompt was successfully loaded, display it
                    Text(prompt.text)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Pass the prompt text to other views
                    NavigationLink("➕ Submit a Song") {
                        SubmitSongView(prompt: prompt.text)
                    }

                    NavigationLink("📜 View Feed") {
                        FeedView(prompt: prompt.text)
                    }

                } else {
                    // If prompt is still loading or not found
                    ProgressView("Loading prompt...")
                        .padding()
                }
            }
            .padding()
            .onAppear {
                // Fetch today’s prompt when the view appears
                promptManager.fetchTodayPrompt()
            }
        }
    }
}
