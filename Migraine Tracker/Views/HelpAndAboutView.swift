import SwiftUI

struct HelpAndAboutView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Migraine Tracker"
    }
    
    var body: some View {
        NavigationView {
            List {
                // App Info Section
                Section {
                    VStack(spacing: 8) {
                        // App Icon and Name
                        VStack(spacing: 4) {
                            Image("Logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Text(appName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Version \(appVersion)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Your personal migraine tracking companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .listRowBackground(Color.clear)
                
                // Help & Support Section
                Section(header: Text("Help & Support")) {
                    NavigationLink(destination: FAQView()) {
                        Label("Frequently Asked Questions", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: UserGuideView()) {
                        Label("User Guide", systemImage: "book")
                    }
                    
                    Button(action: {
                        sendFeedbackEmail()
                    }) {
                        HStack {
                            Label("Send Feedback", systemImage: "envelope")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Links Section
                Section(header: Text("Links")) {
                    Button(action: {
                        openGitHub()
                    }) {
                        HStack {
                            Label("View on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Credits Section
                Section(header: Text("Credits")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Developed with ❤️ for migraine sufferers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Icons: SF Symbols by Apple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Help & About")
        }
    }
    
    private func openGitHub() {
        // Replace with your actual GitHub repository URL
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
        List {
            ForEach(faqItems) { item in
                FAQItemView(item: item)
            }
        }
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
        List {
            ForEach(guideSteps) { step in
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: step.icon)
                        .font(.title2)
                        .foregroundColor(.cyan)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(step.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
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