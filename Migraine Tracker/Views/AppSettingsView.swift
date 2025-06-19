import SwiftUI

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }
}

struct AppSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                Section(header: Text("Appearance")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.headline)

                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button(action: {
                                themeManager.currentTheme = theme
                            }) {
                                HStack {
                                    Image(systemName: themeIconName(for: theme))
                                        .foregroundColor(themeIconColor(for: theme))
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(theme.rawValue)
                                            .foregroundColor(.primary)
                                        Text(themeDescription(for: theme))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if themeManager.currentTheme == theme {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.cyan)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                }

                // Notifications Section
                Section(header: Text("Notifications")) {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.blue)
                            Text("Notification Preferences")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .navigationTitle("App Settings")
        }
    }

    private func themeIconName(for theme: AppTheme) -> String {
        switch theme {
        case .system: return "gear"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }

    private func themeIconColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system: return .secondary
        case .light: return .orange
        case .dark: return .indigo
        }
    }

    private func themeDescription(for theme: AppTheme) -> String {
        switch theme {
        case .system: return "Follows your device settings"
        case .light: return "Always use light appearance"
        case .dark: return "Always use dark appearance"
        }
    }
}

struct NotificationSettingsView: View {
    @State private var dailyReminder = UserDefaults.standard.bool(forKey: "dailyReminder")
    @State private var migraineAlerts = UserDefaults.standard.bool(forKey: "migraineAlerts")
    @State private var weeklyInsights = UserDefaults.standard.bool(forKey: "weeklyInsights")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Reminders")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    Toggle("Daily Check-in Reminder", isOn: $dailyReminder)
                        .onChange(of: dailyReminder) { value in
                            UserDefaults.standard.set(value, forKey: "dailyReminder")
                        }
                    
                    Divider()
                    
                    Toggle("Migraine Pattern Alerts", isOn: $migraineAlerts)
                        .onChange(of: migraineAlerts) { value in
                            UserDefaults.standard.set(value, forKey: "migraineAlerts")
                        }
                    
                    Divider()
                    
                    Toggle("Weekly Insights", isOn: $weeklyInsights)
                        .onChange(of: weeklyInsights) { value in
                            UserDefaults.standard.set(value, forKey: "weeklyInsights")
                        }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .padding(.horizontal)

                Text("These notifications help you stay on track with your migraine management.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .background(Color.white)
        .navigationTitle("Notifications")
        .scrollContentBackground(.hidden)
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView()
    }
}
