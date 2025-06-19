import SwiftUI

struct HelpAndAboutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Migraine Tracker"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // App Info
                VStack(spacing: 12) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                    Text(appName)
                        .font(.title2).bold()
                    Text("Version \(appVersion)")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text("Your personal migraine tracking companion")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Help & Support Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Help & Support").font(.headline)
                    VStack(spacing: 12) {
                        NavigationLink(destination: FAQView()) {
                            helpLink(label: "Frequently Asked Questions", icon: "questionmark.circle")
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        
                        NavigationLink(destination: UserGuideView()) {
                            helpLink(label: "User Guide", icon: "book")
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        
                        Button(action: sendFeedbackEmail) {
                            helpLink(label: "Send Feedback", icon: "envelope", showArrow: true)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .padding(.horizontal)

                // Links Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Links").font(.headline)
                    Button(action: openGitHub) {
                        helpLink(label: "View on GitHub", icon: "chevron.left.forwardslash.chevron.right", showArrow: true)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .padding(.horizontal)

                // Credits
                VStack(alignment: .leading, spacing: 6) {
                    Text("Developed with ❤️ for migraine sufferers")
                        .font(.subheadline).foregroundColor(.secondary)
                    Text("Icons: SF Symbols by Apple")
                        .font(.caption).foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .background(Color.white)
        .scrollContentBackground(.hidden)
        .navigationTitle("Help & About")
        .padding(.bottom, 50)
    }

    private func helpLink(label: String, icon: String, showArrow: Bool = false) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .foregroundColor(.primary)
            Spacer()
            if showArrow {
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }

    private func openGitHub() {
        if let url = URL(string: "https://github.com/tlehman1/Migraine-Tracker") {
            openURL(url)
        }
    }

    private func sendFeedbackEmail() {
        let subject = "\(appName) Feedback - v\(appVersion)"
        let body = """

        
        ---
        App Version: \(appVersion)
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        """

        let emailURL = "mailto:lehmanntim29@gmail.com?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: emailURL) {
            openURL(url)
        }
    }
}


struct FAQView: View {
    let faqItems = [
        FAQItem(question: "How often should I track my migraines?", 
                answer: "It's best to log your migraines as soon as they occur or shortly after. This helps ensure accuracy and provides the most useful data for identifying patterns."),
        
        FAQItem(question: "What triggers should I track?", 
                answer: "Common triggers include stress, weather changes, certain foods, lack of sleep, hormonal changes, and bright lights. Track what seems relevant to your experience."),
        
        FAQItem(question: "How can I identify my personal triggers?", 
                answer: "Use the insights feature to analyze patterns in your data. Look for correlations between triggers and migraine occurrences over time."),
        
        FAQItem(question: "Can I export my data to share with my doctor?", 
                answer: "Yes! Use the Export feature in your profile to generate a report that you can share with healthcare providers."),
        
        FAQItem(question: "Is my data secure?", 
                answer: "Your data is stored locally on your device and is not shared with third parties. You control your information completely."),
        
        FAQItem(question: "How do I set up medication reminders?", 
                answer: "Go to Settings > Notifications to configure reminders for medication, check-ins, and other important migraine management tasks.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(faqItems) { item in
                    FAQItemView(item: item)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                }
            }
            .padding()
        }
        .background(Color.white)
        .scrollContentBackground(.hidden)
        .navigationTitle("FAQ")
    }
}

struct UserGuideView: View {
    let guideSteps = [
        GuideStep(title: "Getting Started",
                  description: "Complete the onboarding to set up your migraine profile and identify potential triggers.",
                  icon: "play.circle"),
        
        GuideStep(title: "Daily Check-ins",
                  description: "Use the '+' button to log new migraines or daily check-ins. Be consistent for best results.",
                  icon: "plus.circle"),
        
        GuideStep(title: "Track Symptoms",
                  description: "Record your symptoms, pain level, duration, and any triggers you notice.",
                  icon: "list.clipboard"),
        
        GuideStep(title: "Review Insights",
                  description: "Check the Insights tab regularly to identify patterns and trends in your migraine data.",
                  icon: "chart.bar"),
        
        GuideStep(title: "Export Data",
                  description: "Share your migraine report with healthcare providers using the export feature.",
                  icon: "square.and.arrow.up")
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 16) {
                    ForEach(guideSteps.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                Image(systemName: guideSteps[index].icon)
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(guideSteps[index].title)
                                        .font(.headline)
                                        .fontWeight(.semibold)

                                    Text(guideSteps[index].description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer(minLength: 0)
                            }

                            // Divider nur, wenn NICHT letztes Element
                            if index < guideSteps.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .padding(.horizontal) // Abstand links/rechts vom Rand
            }
            .padding(.top)
        }
        .background(Color.white)
        .scrollContentBackground(.hidden)
        .navigationTitle("User Guide")
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(item.question)
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(item.answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct GuideStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct HelpAndAboutView_Previews: PreviewProvider {
    static var previews: some View {
        HelpAndAboutView()
    }
}
