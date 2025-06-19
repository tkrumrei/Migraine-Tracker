import SwiftUI
import UserNotifications

struct NotificationView: View {
    var body: some View {
        VStack(spacing: 16) {
            notificationButton(
                title: "Send Reminder",
                color: .blue,
                action: {
                    sendNotification(
                        title: "Reminder",
                        body: "Don't forget to log your migraine today!"
                    )
                }
            )

            notificationButton(
                title: "Send Tip",
                color: .green,
                action: {
                    sendNotification(
                        title: "Health Tip",
                        body: "Drinking plenty of water can reduce the frequency of migraine attacks."
                    )
                }
            )

            notificationButton(
                title: "Send Weather Alert",
                color: .orange,
                action: {
                    sendNotification(
                        title: "Weather Alert",
                        body: "A storm is approaching. This could be a trigger for you."
                    )
                }
            )
        }
        .navigationTitle("Test Notifications")
        .padding()
        .background(Color.white)
    }

    // MARK: - Styled Button Builder
    private func notificationButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Notification Logic
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
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
