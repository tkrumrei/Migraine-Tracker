import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var migraineType = "Nausea"
    @State private var migraineFrequency = "1-3 per M."
    @State private var selectedExternalTriggers: Set<String> = []
    @State private var selectedInternalTriggers: Set<String> = []
    @Binding var isPresented: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let migraineTypes = ["Nausea", "Aura", "Tension", "Cluster", "Other"]
    let frequencies = ["Daily", "1-3 per W.", "1-3 per M.", "Less frequent"]
    
    let externalTriggers = ["Weather", "Noise/Volume", "Allergies", "Travel", "Bright light", "Air quality", "Strong smells", "Crowded spaces"]
    let internalTriggers = ["Stress", "Lack of sleep", "Hormonal changes", "Skipped meals", "Dehydration", "Physical exhaustion", "Caffeine/alcohol", "Intense emotions"]
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.cyan : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding()
                
                // Content based on current step
                Group {
                    switch currentStep {
                    case 0:
                        step1View
                    case 1:
                        step2View
                    case 2:
                        step3View
                    default:
                        EmptyView()
                    }
                }
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .foregroundColor(.cyan)
                    }
                    
                    Spacer()
                    
                    Button(currentStep < 2 ? "Next" : "Get Started") {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            // Save onboarding data and update user profile, then close
                            saveOnboardingData()
                            authViewModel.updateUserProfile(migraineType: migraineType, migraineFrequency: migraineFrequency)
                            isPresented = false
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.cyan)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("On-Boarding \(currentStep + 1)/3")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Step 1: Migraine Type & Frequency
    var step1View: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Migraine Type...")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Type")
                    .font(.headline)
                Picker("Type", selection: $migraineType) {
                    ForEach(migraineTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Text("Frequency")
                    .font(.headline)
                    .padding(.top)
                Picker("Frequency", selection: $migraineFrequency) {
                    ForEach(frequencies, id: \.self) { freq in
                        Text(freq).tag(freq)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // Step 2: Known Triggers
    var step2View: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Known Triggers...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // External Triggers
                VStack(alignment: .leading, spacing: 10) {
                    Text("External:")
                        .font(.headline)
                    
                    ForEach(externalTriggers, id: \.self) { trigger in
                        HStack {
                            Image(systemName: selectedExternalTriggers.contains(trigger) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedExternalTriggers.contains(trigger) ? .cyan : .gray)
                            Text(trigger)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedExternalTriggers.contains(trigger) {
                                selectedExternalTriggers.remove(trigger)
                            } else {
                                selectedExternalTriggers.insert(trigger)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Internal Triggers
                VStack(alignment: .leading, spacing: 10) {
                    Text("Internal:")
                        .font(.headline)
                    
                    ForEach(internalTriggers, id: \.self) { trigger in
                        HStack {
                            Image(systemName: selectedInternalTriggers.contains(trigger) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedInternalTriggers.contains(trigger) ? .cyan : .gray)
                            Text(trigger)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedInternalTriggers.contains(trigger) {
                                selectedInternalTriggers.remove(trigger)
                            } else {
                                selectedInternalTriggers.insert(trigger)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
    
    // Step 3: Overview
    var step3View: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(.cyan)
                    Text("Migraine Type:")
                        .fontWeight(.semibold)
                    Text(migraineType)
                }
                
                HStack {
                    Text("Frequency:")
                        .fontWeight(.semibold)
                    Text(migraineFrequency)
                }
                
                Text("Triggers:")
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("External:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(Array(selectedExternalTriggers), id: \.self) { trigger in
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                                .font(.caption)
                            Text(trigger)
                                .font(.caption)
                        }
                    }
                    
                    if selectedExternalTriggers.isEmpty {
                        Text("None selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Internal:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(Array(selectedInternalTriggers), id: \.self) { trigger in
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                                .font(.caption)
                            Text(trigger)
                                .font(.caption)
                        }
                    }
                    
                    if selectedInternalTriggers.isEmpty {
                        Text("None selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    func saveOnboardingData() {
        // Save to UserDefaults or Core Data
        UserDefaults.standard.set(migraineType, forKey: "migraineType")
        UserDefaults.standard.set(migraineFrequency, forKey: "migraineFrequency")
        UserDefaults.standard.set(Array(selectedExternalTriggers), forKey: "externalTriggers")
        UserDefaults.standard.set(Array(selectedInternalTriggers), forKey: "internalTriggers")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isPresented: .constant(true))
            .environmentObject(AuthViewModel())
    }
}
