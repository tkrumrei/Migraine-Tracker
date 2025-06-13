import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    @State private var migraineType: String? = nil
    @State private var migraineFrequency: String? = nil
    @State private var selectedExternalTriggers: Set<String> = []
    @State private var selectedInternalTriggers: Set<String> = []
    @State private var customTypes: [String] = []
    @State private var showAddTypeField = false
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
                VStack(spacing:0) {
                    Divider()
                        .padding(.horizontal)
                    HStack {
                        if currentStep > 0 {
                            Button("Back") {
                                currentStep -= 1
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.cyan)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(currentStep < 2 ? "Next" : "Get Started") {
                            if currentStep < 2 {
                                currentStep += 1
                            } else {
                                // Save onboarding data and update user profile, then close
                                saveOnboardingData()
                                authViewModel.updateUserProfile(
                                    migraineType: migraineType ?? "Unknown",
                                    migraineFrequency: migraineFrequency ?? "Unknown"
                                )
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
            }
        }
    }
    
    // Step 1: Migraine Type & Frequency
    var step1View: some View {
        VStack(spacing: 30) {
            
            // Header mit Titel + Fortschritt
            VStack(spacing: 10) {
                    ZStack {
                        Text("On-Boarding")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Spacer()
                            Text("1/3")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)
                }

            // Alle Inhalte mittig
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    // Überschrift
                    Text("Migraine Type...")
                        .font(.title2)
                        .fontWeight(.bold)

                    // GRAUER KASTEN um Type + Frequency
                    VStack(alignment: .leading, spacing: 16) {
                        // Type-Zeile
                        HStack {
                            Text("Type")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)

                            Menu {
                                ForEach(migraineTypes, id: \.self) { type in
                                    Button(action: {
                                        migraineType = type
                                    }) {
                                        Text(type)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(migraineType ?? "Choose a type")
                                        .foregroundColor(migraineType == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down") // ↓ das Dropdown-Symbol
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }

                        // Frequency-Zeile
                        HStack {
                            Text("Frequency")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)

                            Menu {
                                ForEach(frequencies, id: \.self) { type in
                                    Button(action: {
                                        migraineFrequency = type
                                    }) {
                                        Text(type)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(migraineFrequency ?? "Choose a frequency")
                                        .foregroundColor(migraineFrequency == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down") // ↓ das Dropdown-Symbol
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1)) // ← grauer Kasten
                    .cornerRadius(12)

                    // Plus-Button zentriert
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddTypeField.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.cyan)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)

                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)

                Spacer()
            }
            
            Spacer()
        }
    }
    
    // Step 2: Known Triggers
    var step2View: some View {
        ScrollView {
            
            VStack(spacing: 10) {
                    ZStack {
                        Text("On-Boarding")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Spacer()
                            Text("2/3")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)
                }
            
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
            
            ZStack {
                // Zentrierter Titel
                Text("On-Boarding")
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)

                // Fortschritt rechts oben
                HStack {
                    Spacer()
                    Text("3/3")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
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
                    Text(migraineType ?? "None")
                }
                
                HStack {
                    Text("Frequency:")
                        .fontWeight(.semibold)
                    Text(migraineFrequency ?? "None")
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
