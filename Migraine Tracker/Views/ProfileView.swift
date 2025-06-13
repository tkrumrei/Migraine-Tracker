import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        List {
            Section(header: Text("User Information")) {
                if let user = authViewModel.currentUser {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listRowBackground(Color(.systemGray6)) // Gray background for section

            Section(header: Text("Settings")) {
                NavigationLink(destination: Text("Onboarding Placeholder")) {
                    Label("Edit Onboarding", systemImage: "doc.text.magnifyingglass")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: Text("Profile Settings Placeholder")) {
                    Label("Edit Profile", systemImage: "person.fill")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: Text("App Settings Placeholder")) {
                    Label("App Settings", systemImage: "gear")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: Text("Tips & Tricks Placeholder")) {
                    Label("Tips & Tricks", systemImage: "lightbulb.fill")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: Text("Export Report Placeholder")) {
                    Label("Export Report", systemImage: "square.and.arrow.up.fill")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: Text("Help & About Placeholder")) {
                    Label("Help & About", systemImage: "questionmark.circle.fill")
                }
                .listRowBackground(Color(.systemGray6))
                
                NavigationLink(destination: NotificationView()) {
                    Label("Notifications", systemImage: "bell.badge.fill")
                }
                .listRowBackground(Color(.systemGray6))
            }

            Section {
                Button(action: { authViewModel.logout() }) {
                    HStack {
                        Spacer()
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .listRowBackground(Color(.systemGray6))
            }
        }
        .listStyle(PlainListStyle()) // Plain style for white background
        .background(Color.white) // Explicitly white background
        .navigationTitle("Profile")
        .onAppear {
            setupNotifications()
        }
    }

    private func setupNotifications() {
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

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(AuthViewModel())
        }
    }
}
