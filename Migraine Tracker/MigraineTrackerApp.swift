import SwiftUI
import UserNotifications

@main
struct MigraineTrackerApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Request notification permission when the app starts
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
