/*
import SwiftUI
import UserNotifications


struct HomeView: View {
    @State private var showUsernamePrompt = false
    @State private var usernameInput = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @StateObject private var promptManager = PromptManager()
    @State private var navigateToSubmit = false
    @State private var navigateToFeed = false
    @State private var loadingAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 🔥 2000s orange-to-green gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.green]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if promptManager.prompt == nil {
                        VStack(spacing: 20) {
                            Text("🎮 Loading...")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // 🔥 Retro-style spinning loader
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(loadingAnimation ? 360 : 0))
                                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: loadingAnimation)
                                .onAppear {
                                    promptManager.fetchTodayPrompt()
                                    if UserDefaults.standard.string(forKey: "username") == nil {
                                        showUsernamePrompt = true
                                    }                                }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("DAILYDROP")
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text("Today's Prompt:")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("“\(promptManager.prompt?.text ?? "No prompt today.")”")
                                .font(.title3)
                                .italic()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Submit Button
                            NavigationLink(destination: SubmitSongView(prompt: promptManager.prompt?.text ?? ""), isActive: $navigateToSubmit) {
                                Button(action: {
                                    navigateToSubmit = true
                                }) {
                                    Text("🎵 Submit Today's Song")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.8))
                                        .foregroundColor(.black)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                            
                            // View Feed Button
                            NavigationLink(destination: FeedView(prompt: promptManager.prompt?.text ?? ""), isActive: $navigateToFeed) {
                                Button(action: {
                                    navigateToFeed = true
                                }) {
                                    Text("📜 View Today's Feed")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.5))
                                        .foregroundColor(.black)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                promptManager.fetchTodayPrompt()
                requestNotificationPermission()
            }
            .navigationBarHidden(true)
            
            // 🔥 Paste the .sheet here!
            .sheet(isPresented: $showUsernamePrompt) {
                VStack(spacing: 20) {
                    Text("Create Your Profile 🎮")
                        .font(.title)
                        .padding()
                    
                    TextField("Enter username", text: $usernameInput)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Button("Select Profile Picture") {
                            showImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Button("Save Profile") {
                        UserDefaults.standard.set(usernameInput, forKey: "username")
                        
                        if let selectedImage = selectedImage {
                            let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 150, height: 150)) // 🔥 Resize here properly
                            if let imageData = resizedImage.jpegData(compressionQuality: 0.3) { // 🔥 Extra compression
                                let base64String = imageData.base64EncodedString()
                                UserDefaults.standard.set(base64String, forKey: "profilePictureBase64")
                            }
                        }
                        
                        showUsernamePrompt = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(usernameInput.isEmpty)
                    .padding()
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                }
            }
        }
       
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // 🔥 Request permission to send notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted!")
                scheduleDailyNotification()
            } else {
                print("❌ Notification permission denied.")
            }
        }
    }

    // 🔥 Schedule a daily reminder notification
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = " DailyDrop Time!"
        content.body = "What's your song today? 🎶 Submit it now!"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 19 // 7 PM local device time — change if you want!

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyDropReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Daily reminder notification scheduled!")
            }
        }
    }

}

*/

import SwiftUI
import UserNotifications

struct HomeView: View {
    @State private var showUsernamePrompt = false
    @State private var usernameInput = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @StateObject private var promptManager = PromptManager()
    @State private var navigateToSubmit = false
    @State private var navigateToFeed = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if promptManager.prompt == nil {
                        VStack(spacing: 12) {
                            Text("Loading DailyDrop...")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Text("DailyDrop")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.top)

                            Text("Today's Prompt")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text("“\(promptManager.prompt?.text ?? "No prompt today.")”")
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            // Submit Button
                            NavigationLink(destination: SubmitSongView(prompt: promptManager.prompt?.text ?? ""), isActive: $navigateToSubmit) {
                                Button(action: {
                                    navigateToSubmit = true
                                }) {
                                    Text("Submit Today's Song")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue.opacity(0.8))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)

                            // View Feed Button
                            NavigationLink(destination: FeedView(prompt: promptManager.prompt?.text ?? ""), isActive: $navigateToFeed) {
                                Button(action: {
                                    navigateToFeed = true
                                }) {
                                    Text("View Today's Feed")
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                promptManager.fetchTodayPrompt()
                requestNotificationPermission()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showUsernamePrompt) {
                profileSetupSheet
            }
        }
    }
    
    // 🔥 Profile Setup Sheet
    var profileSetupSheet: some View {
        VStack(spacing: 20) {
            Text("Create Your Profile")
                .font(.title2)
                .padding()

            TextField("Enter username", text: $usernameInput)
                .textFieldStyle(.roundedBorder)
                .padding()

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Button("Select Profile Picture") {
                    showImagePicker = true
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Save Profile") {
                UserDefaults.standard.set(usernameInput, forKey: "username")
                if let selectedImage = selectedImage {
                    let resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 150, height: 150))
                    if let imageData = resizedImage.jpegData(compressionQuality: 0.3) {
                        let base64String = imageData.base64EncodedString()
                        UserDefaults.standard.set(base64String, forKey: "profilePictureBase64")
                    }
                }
                showUsernamePrompt = false
            }
            .buttonStyle(.borderedProminent)
            .disabled(usernameInput.isEmpty)

            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    // 🔥 Resize profile picture
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        let rect = CGRect(origin: .zero, size: newSize)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
    
    // 🔥 Notification setup
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                scheduleDailyNotification()
            }
        }
    }

    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "DailyDrop Reminder"
        content.body = "What's your song today? 🎶"
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 19

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyDropReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
