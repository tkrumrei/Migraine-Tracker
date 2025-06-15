import SwiftUI
import UserNotifications

struct NotificationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Send Reminder") {
                sendNotification(title: "Reminder", body: "Don't forget to log your migraine today!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Send Tip") {
                sendNotification(title: "Health Tip", body: "Drinking plenty of water can reduce the frequency of migraine attacks.")
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Send Weather Alert") {
                sendNotification(title: "Weather Alert", body: "A storm is approaching. This could be a trigger for you.")
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .navigationTitle("Test Notifications")
        .padding()
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // 1 Sekunde Verzögerung
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled: \(title)")
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
