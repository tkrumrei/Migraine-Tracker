import SwiftUI

struct OnboardingView: View {
    @State private var showProfileSetup = false
    @State private var showMainTabView = false
    @State private var currentStep = 0
    @State private var migraineType: String? = nil
    @State private var migraineFrequency: String? = nil
    @State private var selectedExternalTriggers: Set<String> = []
    @State private var selectedInternalTriggers: Set<String> = []
    @State private var customTypes: [String] = []
    @State private var additionalEntries: [MigraineEntry] = []
    @State private var triggerStates: [String: Bool?] = [:]
    @State private var showOnboarding = true
    @State private var showExternalTriggerSheet = false
    @State private var showInternalTriggerSheet = false
    @State private var showAddTypeField = false
    @State private var navigateToSetup = false
    @State private var showValidationAlert = false
    @Binding var isPresented: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var authService: AuthService
    
    let migraineTypes = ["Nausea", "Aura", "Tension", "Cluster", "Other"]
    let frequencies = ["Daily", "1-3 per W.", "1-3 per M.", "Less frequent"]
    
    let externalTriggers = ["Weather", "Noise/Volume", "Allergies", "Travel", "Bright light", "Air quality", "Strong smells", "Crowded spaces"]
    let internalTriggers = ["Stress", "Lack of sleep", "Hormonal changes", "Skipped meals", "Dehydration", "Physical exhaustion", "Caffeine/alcohol", "Intense emotions"]
    
    struct MigraineEntry: Identifiable {
        let id = UUID()
        var type: String? = nil
        var frequency: String? = nil
    }
    
    struct TriggerClassificationSheet: View {
        let title: String
        let options: [String]
        @Binding var triggerStates: [String: Bool?]
        @Binding var selectedTriggers: Set<String>

        @Environment(\.dismiss) var dismiss
        @State private var localStates: [String: Bool?] = [:]

        var body: some View {
            NavigationView {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Leave any item untouched if you're not sure.")
                                        .font(.subheadline)

                            Text("🔁 Tap to cycle through:")
                                .font(.subheadline)
                            Spacer()
                            HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "square")
                                            .foregroundColor(.gray)
                                        Text("Not sure")
                                    }

                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.square.fill")
                                            .foregroundColor(.green)
                                        Text("Known trigger")
                                    }

                                    HStack(spacing: 4) {
                                        Image(systemName: "x.square.fill")
                                            .foregroundColor(.red)
                                        Text("Not a trigger")
                                    }
                                }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }

                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            cycleState(for: option)
                        }) {
                            HStack {
                                Image(systemName: iconName(for: option))
                                    .foregroundColor(color(for: option))
                                Text(option)
                            }
                        }
                    }
                }
                .navigationTitle(title)
                .navigationBarItems(trailing: Button("Save") {
                    // Update triggerStates global
                    for option in options {
                        triggerStates[option] = localStates[option]
                    }

                    // Save only selected (known = true)
                    selectedTriggers = Set(localStates.compactMap { key, value in
                        value == true ? key : nil
                    })

                    dismiss()
                })
                .onAppear {
                    for option in options {
                        localStates[option] = triggerStates[option] ?? nil
                    }
                }
            }
        }

        private func cycleState(for option: String) {
            switch localStates[option] ?? nil {
            case nil:
                localStates[option] = true
            case true:
                localStates[option] = false
            case false:
                localStates[option] = nil
            default:
                break
            }
        }

        private func iconName(for option: String) -> String {
            switch localStates[option] ?? nil {
            case nil: return "square"
            case true: return "checkmark.square.fill"
            case false: return "x.square.fill"
            default: return "questionmark.square.fill"
            }
        }

        private func color(for option: String) -> Color {
            switch localStates[option] ?? nil {
            case nil: return .gray
            case true: return .green
            case false: return .red
            default: return .gray
            }
        }
    }
    
    // Liefert alle Trigger + deren Status zurück
    var allTriggerStates: [(name: String, isTrigger: Bool?)] {
        triggerStates.map { key, value in
            (name: key, isTrigger: value)
        }
        .sorted { $0.name < $1.name }
    }
    
    // Validation computed properties
    private var isStep1Valid: Bool {
        migraineType != nil && migraineFrequency != nil
    }
    
    private var isStep2Valid: Bool {
        !selectedExternalTriggers.isEmpty || triggerStates.values.contains(true)
    }
    
    private var isStep3Valid: Bool {
        !selectedInternalTriggers.isEmpty || triggerStates.values.contains(true)
    }
    
    private var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: return isStep1Valid
        case 1: return isStep2Valid
        default: return true
        }
    }
    
    private var validationMessage: String {
        switch currentStep {
        case 0: return "Please select both your migraine type and frequency before continuing."
        case 1: return "Please identify at least one external or internal trigger before continuing."
        default: return "Please complete all required fields."
        }
    }

    // Icon abhängig vom Status (z.B. checkmark)
    private func iconName(for option: String) -> String {
        switch triggerStates[option] ?? nil {
            case true:
                return "checkmark.square.fill"
            case false:
                return "x.square.fill"
            default:
                return "square"
            }
    }

    // Farbe abhängig vom Status (z.B. grün/rot/grau)
    private func color(for option: String) -> Color {
        switch triggerStates[option] ?? nil {
        case true:
            return .green
        case false:
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        NavigationStack {
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
                
                VStack(spacing: 10) {
                    ZStack {
                        Text("On-Boarding")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack {
                            Spacer()
                            Text("\(currentStep + 1)/3")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)
                }
                
                ScrollView {
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
                }
                
                Spacer()
                
                // Navigation buttons
                VStack(spacing: 10) {
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
                            if isCurrentStepValid {
                                if currentStep < 2 {
                                    currentStep += 1
                                } else {
                                    saveOnboardingData()
                                    authViewModel.updateUserProfile(
                                        migraineType: migraineType ?? "Unknown",
                                        migraineFrequency: migraineFrequency ?? "Unknown"
                                    )
                                    navigateToSetup = true
                                }
                            } else {
                                showValidationAlert = true
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(isCurrentStepValid ? Color.cyan : Color.gray)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 70)
                    .padding(.horizontal, 10)
                }
            }
            .navigationDestination(isPresented: $navigateToSetup) {
                ProfileSetupView(showMainTabView: $showMainTabView)
                    .navigationBarBackButtonHidden(true)
            }
            .fullScreenCover(isPresented: $showMainTabView) {
                MainTabView()
            }
            .alert("Please Complete This Step", isPresented: $showValidationAlert) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // Step 1: Migraine Type & Frequency
    var step1View: some View {
        VStack(spacing: 30) {

            // Alle Inhalte mittig
            HStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Überschrift
                    Text("Migraine Type...")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Fester grauer Kasten
                    VStack(alignment: .leading, spacing: 16) {
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
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }

                        HStack {
                            Text("Frequency")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)

                            Menu {
                                ForEach(frequencies, id: \.self) { freq in
                                    Button(action: {
                                        migraineFrequency = freq
                                    }) {
                                        Text(freq)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(migraineFrequency ?? "Choose frequency")
                                        .foregroundColor(migraineFrequency == nil ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Dynamische zusätzliche Kästen
                    ForEach($additionalEntries) { $entry in
                        VStack(alignment: .leading, spacing: 16) {
                            
                            // Minus-Button oben rechts
                            HStack {
                                Spacer()
                                Button {
                                    if let index = additionalEntries.firstIndex(where: { $0.id == entry.id }) {
                                        additionalEntries.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }

                            // TYPE
                            HStack {
                                Text("Type")
                                    .font(.headline)
                                    .frame(width: 100, alignment: .leading)

                                Menu {
                                    ForEach(migraineTypes, id: \.self) { type in
                                        Button { entry.type = type } label: {
                                            Text(type)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(entry.type ?? "Choose a type")
                                            .foregroundColor(entry.type == nil ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }

                            // FREQUENCY
                            HStack {
                                Text("Frequency")
                                    .font(.headline)
                                    .frame(width: 100, alignment: .leading)

                                Menu {
                                    ForEach(frequencies, id: \.self) { freq in
                                        Button { entry.frequency = freq } label: {
                                            Text(freq)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(entry.frequency ?? "Choose frequency")
                                            .foregroundColor(entry.frequency == nil ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Plus-Button zentriert
                    HStack {
                        Spacer()
                        Button {
                            additionalEntries.append(MigraineEntry())
                        } label: {
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
        let externalTriggerStates = allTriggerStates.filter {
            externalTriggers.contains($0.name)
        }
        let internalTriggerStates = allTriggerStates.filter {
            internalTriggers.contains($0.name)
        }
        return ScrollView {
            VStack(spacing: 30) {

                // Inhalt
                HStack {
                    Spacer()

                    VStack(alignment: .leading, spacing: 24) {
                        Text("Known Triggers...")
                            .font(.title2)
                            .fontWeight(.bold)

                        // External Trigger Box
                        VStack(alignment: .leading, spacing: 12) {
                            Text("external:")
                                .font(.headline)
                                .bold()

                            let anyExternalSelected = externalTriggerStates.contains { $0.isTrigger != nil }

                            if !anyExternalSelected {
                                Text("Nothing chosen yet.")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            } else {
                                ForEach(externalTriggerStates.sorted(by: sortByTriggerStatus), id: \.name) { entry in
                                    HStack {
                                        Image(systemName: iconName(for: entry.name))
                                            .foregroundColor(color(for: entry.name))
                                        Text(entry.name)
                                        Spacer()
                                        if let isTrigger = entry.isTrigger {
                                            Text(isTrigger ? "Trigger" : "Not a trigger")
                                                .font(.caption)
                                                .foregroundColor(isTrigger ? .green : .red)
                                        } else {
                                            Text("Unselected")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }

                            HStack {
                                Spacer()
                                Button(action: {
                                    showExternalTriggerSheet = true
                                }) {
                                    Image(systemName: externalTriggerStates.contains(where: { $0.isTrigger != nil }) ? "pencil.circle" : "plus.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.cyan)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)

                        // Internal Trigger Box
                        VStack(alignment: .leading, spacing: 12) {
                            Text("internal:")
                                .font(.headline)
                                .bold()

                            let anyInternalSelected = internalTriggerStates.contains { $0.isTrigger != nil }
                            
                            if !anyInternalSelected {
                                Text("Nothing chosen yet.")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            } else {
                                ForEach(internalTriggerStates.sorted(by: sortByTriggerStatus), id: \.name) { entry in
                                    HStack {
                                        Image(systemName: iconName(for: entry.name))
                                            .foregroundColor(color(for: entry.name))
                                        Text(entry.name)
                                        Spacer()
                                        if let isTrigger = entry.isTrigger {
                                            Text(isTrigger ? "Trigger" : "Not a trigger")
                                                .font(.caption)
                                                .foregroundColor(isTrigger ? .green : .red)
                                        } else {
                                            Text("Unselected")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }

                            HStack {
                                Spacer()
                                Button(action: {
                                    showInternalTriggerSheet = true
                                }) {
                                    Image(systemName: internalTriggerStates.contains(where: { $0.isTrigger != nil }) ? "pencil.circle" : "plus.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.cyan)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)

                    Spacer()
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showExternalTriggerSheet) {
            TriggerClassificationSheet(
                title: "External Triggers",
                options: externalTriggers,
                triggerStates: $triggerStates,
                selectedTriggers: $selectedExternalTriggers
            )
        }
        .sheet(isPresented: $showInternalTriggerSheet) {
            TriggerClassificationSheet(
                title: "Internal Triggers",
                options: internalTriggers,
                triggerStates: $triggerStates,
                selectedTriggers: $selectedInternalTriggers
            )
        }
    }
    
    // Step 3: Overview
    var step3View: some View {
        let externalTrue = triggerStates.filter { externalTriggers.contains($0.key) && $0.value == true }.map(\.key)
        let externalFalse = triggerStates.filter { externalTriggers.contains($0.key) && $0.value == false }.map(\.key)

        _ = triggerStates.filter { internalTriggers.contains($0.key) && $0.value == true }.map(\.key)
        _ = triggerStates.filter { internalTriggers.contains($0.key) && $0.value == false }.map(\.key)
        
        return ScrollView {
            VStack{
                Text("Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)

                // 1. Box: Migraine Info
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Migraine Info")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Button(action: {
                            currentStep = 0
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.cyan)
                        }
                    }

                    // Haupt-Eintrag
                    if let migraineType = migraineType, let migraineFrequency = migraineFrequency {
                        HStack {
                            Text("Type:")
                                .fontWeight(.semibold)
                            Text(migraineType)
                        }

                        HStack {
                            Text("Frequency:")
                                .fontWeight(.semibold)
                            Text(migraineFrequency)
                        }
                    } else {
                        Text("None selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    // Zusätzliche Einträge
                    ForEach(additionalEntries) { entry in
                        Divider()
                        if let type = entry.type, let freq = entry.frequency {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Type:")
                                        .fontWeight(.semibold)
                                    Text(type)
                                }
                                HStack {
                                    Text("Frequency:")
                                        .fontWeight(.semibold)
                                    Text(freq)
                                }
                            }
                        }
                    }

                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)

                // 2. Box: External Triggers
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("External Triggers")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Button(action: {
                            currentStep = 1
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.cyan)
                        }
                    }

                    if externalTrue.isEmpty && externalFalse.isEmpty {
                        Text("None selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if !externalTrue.isEmpty && !externalFalse.isEmpty {
                        // Beide vorhanden → nebeneinander anzeigen
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Known Triggers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(externalTrue, id: \.self) { trigger in
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                        Text(trigger)
                                            .font(.caption)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Not a Trigger")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(externalFalse, id: \.self) { trigger in
                                    HStack {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                        Text(trigger)
                                            .font(.caption)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        // Nur eine der beiden Gruppen vorhanden → ganz normal untereinander
                        if !externalTrue.isEmpty {
                            Text("Known Triggers")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ForEach(externalTrue, id: \.self) { trigger in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                    Text(trigger)
                                        .font(.caption)
                                }
                            }
                        }

                        if !externalFalse.isEmpty {
                            Text("Not a Trigger")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ForEach(externalFalse, id: \.self) { trigger in
                                HStack {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                    Text(trigger)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)

                // 3. Box: Internal Triggers
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Internal Triggers")
                            .font(.headline)
                            .bold()
                        Spacer()
                        Button(action: {
                            currentStep = 1
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.cyan)
                        }
                    }

                    let internalTrue = triggerStates.filter { $0.value == true && internalTriggers.contains($0.key) }.map { $0.key }
                    let internalFalse = triggerStates.filter { $0.value == false && internalTriggers.contains($0.key) }.map { $0.key }

                    if internalTrue.isEmpty && internalFalse.isEmpty {
                        Text("None selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else if !internalTrue.isEmpty && !internalFalse.isEmpty {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Known Triggers")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(internalTrue, id: \.self) { trigger in
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                        Text(trigger)
                                            .font(.caption)
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Not a Trigger")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                ForEach(internalFalse, id: \.self) { trigger in
                                    HStack {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                        Text(trigger)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    } else {
                        if !internalTrue.isEmpty {
                            Text("Known Triggers")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ForEach(internalTrue, id: \.self) { trigger in
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                    Text(trigger)
                                        .font(.caption)
                                }
                            }
                        }

                        if !internalFalse.isEmpty {
                            Text("Not a Trigger")
                                .font(.caption)
                                .foregroundColor(.gray)
                            ForEach(internalFalse, id: \.self) { trigger in
                                HStack {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                    Text(trigger)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)

                Spacer()
            }
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
    struct PreviewWrapper: View {
        @State private var triggerStates: [String: Bool?] = [:]
        @State private var isPresented: Bool = true
        
        
        var body: some View {
            OnboardingView(
                isPresented: $isPresented
            )
            .environmentObject(AuthViewModel())
            .environmentObject(AuthService())
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}

func sortByTriggerStatus(_ lhs: (name: String, isTrigger: Bool?), _ rhs: (name: String, isTrigger: Bool?)) -> Bool {
    let lhsRank = rank(lhs.isTrigger)
    let rhsRank = rank(rhs.isTrigger)
    
    if lhsRank == rhsRank {
        return lhs.name < rhs.name
    } else {
        return lhsRank < rhsRank
    }
}

func rank(_ status: Bool?) -> Int {
    switch status {
    case true: return 0    // Known Trigger first
    case false: return 1   // Not a Trigger second
    default: return 2      // Unselected last
    }
}
