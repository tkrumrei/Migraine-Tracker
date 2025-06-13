import SwiftUI
import UserNotifications

struct NotificationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Button("Erinnerung senden") {
                sendNotification(title: " Erinnerung", body: "Vergessen Sie nicht, heute Ihre Migräne zu protokollieren!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Tipp senden") {
                sendNotification(title: "Gesundheitstipp", body: "Viel Wasser zu trinken kann die Häufigkeit von Migräneanfällen verringern.")
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Wetter-Warnung senden") {
                sendNotification(title: "Wetter-Warnung", body: "Ein Sturm nähert sich. Das könnte ein Auslöser für Sie sein.")
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

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 Sekunden Verzögerung
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler beim Senden der Benachrichtigung: \(error.localizedDescription)")
            } else {
                print("Benachrichtigung geplant: \(title)")
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
