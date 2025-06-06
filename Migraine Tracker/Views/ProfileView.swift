import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationStatus = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Benutzerinformationen")) {
                    if let user = authViewModel.currentUser {
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title)
                            Text(user.email)
                                .font(.subheadline)
                        }
                        .padding()
                    }
                }
                
                Section("Einstellungen") {
                    NavigationLink("Edit Onboarding", destination: Text("Onboarding Placeholder"))
                    NavigationLink("Profile Settings", destination: Text("Profile Settings Placeholder"))
                    NavigationLink("App Settings", destination: Text("App Settings Placeholder"))
                    NavigationLink("Tips & Tricks", destination: Text("Tips & Tricks Placeholder"))
                    NavigationLink("Export Report", destination: Text("Export Report Placeholder"))
                    NavigationLink("Help & About", destination: Text("Help & About Placeholder"))
                }
                
                Section("Test-Funktionen") {
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Nachrichten senden") {
                            sendTestNotification()
                        }
                        .foregroundColor(.blue)
                        
                        Button("Berechtigung prüfen") {
                            checkNotificationStatus()
                        }
                        .foregroundColor(.orange)
                        .font(.caption)
                        
                        if !notificationStatus.isEmpty {
                            Text(notificationStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15.0)
                    }
                }
            }
            .navigationTitle("Profil")
            .onAppear {
                setupNotifications()
            }
        }
    }
    
    private func setupNotifications() {
        // Delegate setzen für Benachrichtigungen im Vordergrund
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    notificationStatus = "Fehler: \(error.localizedDescription)"
                } else if granted {
                    notificationStatus = "✅ Benachrichtigungen erlaubt"
                } else {
                    notificationStatus = "❌ Benachrichtigungen verweigert"
                }
            }
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    notificationStatus = "✅ Berechtigung erteilt"
                case .denied:
                    notificationStatus = "❌ Berechtigung verweigert - Gehen Sie zu Einstellungen"
                case .notDetermined:
                    notificationStatus = "❓ Berechtigung noch nicht angefragt"
                    requestNotificationPermission()
                case .provisional:
                    notificationStatus = "⚠️ Vorläufige Berechtigung"
                case .ephemeral:
                    notificationStatus = "📱 Temporäre Berechtigung"
                @unknown default:
                    notificationStatus = "❓ Unbekannter Status"
                }
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Migräne Tracker"
        content.body = "🩺 Test-Nachricht: Vergessen Sie nicht, Ihre Symptome heute zu erfassen!"
        content.sound = .default
        content.badge = 1
        
        // Benachrichtigung nach 3 Sekunden senden
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    notificationStatus = "❌ Fehler: \(error.localizedDescription)"
                } else {
                    notificationStatus = "✅ Benachrichtigung in 3 Sekunden..."
                }
            }
        }
    }
}

// Neue Klasse für Benachrichtigungen im Vordergrund
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // Benachrichtigungen auch im Vordergrund anzeigen
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
