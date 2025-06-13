import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

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
                    NavigationLink("Notifications", destination: NotificationView()) // Hier die neue Ansicht einfügen
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
            if let error = error {
                print("Notification permission request error: \(error.localizedDescription)")
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
