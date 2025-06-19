import SwiftUI

enum CheckInDetailType: Identifiable {
    case sleep, body, environment

    var id: String {
        switch self {
        case .sleep: return "sleep"
        case .body: return "body"
        case .environment: return "environment"
        }
    }
}

struct CheckInView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var mood = 3
    @State private var sleepQuality = 5.0
    @State private var sleepHours = 7.0
    @State private var stressLevel = 5.0
    @State private var notes = ""
    @State private var showingSymptoms = false
    @State private var showingEnvironment = false
    @State private var hasSymptoms = false
    @State private var hasEnvironmentalFactors = false
    @State private var showingSaveAlert = false
    @State private var saveSuccess = false
    
    @State private var showSleepSheet = false
    @State private var showBodySheet = false
    @State private var showEnvironmentSheet = false

    @State private var activePopup: CheckInDetailType?
    
    // Sample symptoms and environmental factors
    @Binding var selectedSymptoms: Set<String>
    @Binding var selectedFactors: Set<String>
    @State private var didEnterSleep = false
    
    // Mood emojis in order: 😭🙁😐🙂😁
    let moodEmojis = ["😭", "🙁", "😐", "🙂", "😁"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Date Section
                    sectionCard {
                        DateSelectionView(selectedDate: $selectedDate)
                    }

                    // Mood Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Mood").font(.headline)
                                Spacer()
                                Text(moodDescription)
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 5) {
                                ForEach(1...5, id: \.self) { index in
                                    Button(action: { mood = index }) {
                                        Text(moodEmojis[index - 1])
                                            .font(.title)
                                            .opacity(index == mood ? 1.0 : 0.3)
                                            .scaleEffect(index == mood ? 1.2 : 1.0)
                                            .animation(.easeInOut(duration: 0.2), value: mood)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 5)
                        }
                    }

                    // Sleep Section
                    sectionCard {
                        VStack(alignment: .leading) {
                            Text("Sleep").font(.headline)
                            HStack {
                                Image(systemName: "moon.zzz")
                                    .foregroundColor(.purple)

                                Text(didEnterSleep ? "Sleep:" : "Add Sleep Info")
                                    .foregroundColor(.gray)

                                Spacer()

                                DetailActionButton(isEditMode: didEnterSleep) {
                                    activePopup = .sleep
                                }
                            }

                            if didEnterSleep {
                                HStack {
                                    Text("Quality: \(Int(sleepQuality))/10")
                                    Spacer()
                                    Text("Hours: \(sleepHours, specifier: "%.1f") h")
                                    Spacer()
                                }
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                            }
                        }
                    }

                    // Stress Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Stress").font(.headline)
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.orange)
                                Text("How stressed do you feel?")
                                Spacer()
                                Text("\(Int(stressLevel))/10")
                                    .foregroundColor(.secondary)
                            }

                            Slider(value: $stressLevel, in: 1...10, step: 1)

                            HStack {
                                Text("Relaxed")
                                Spacer()
                                Text("Stressed")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }

                    // Symptoms & Environment Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Symptoms & Environment").font(.headline)
                            // Body Symptoms
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.pink)

                                    Text(selectedSymptoms.isEmpty ? "Add Body Symptoms" : "Symptoms:")
                                        .foregroundColor(.gray)

                                    Spacer()

                                    DetailActionButton(isEditMode: !selectedSymptoms.isEmpty) {
                                        activePopup = .body
                                    }
                                }

                                if !selectedSymptoms.isEmpty {
                                    Text(selectedSymptoms.joined(separator: ", "))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            
                            Divider()

                            // Environment
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)

                                    Text(selectedFactors.isEmpty ? "Add Environment Factors" : "Environment:")
                                        .foregroundColor(.gray)

                                    Spacer()

                                    DetailActionButton(isEditMode: !selectedFactors.isEmpty) {
                                        activePopup = .environment
                                    }
                                }

                                if !selectedFactors.isEmpty {
                                    Text(selectedFactors.joined(separator: ", "))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                    }

                    // Notes Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Additional Notes").font(.headline)
                                Image(systemName: "note.text")
                                    .foregroundColor(.cyan)
                            }

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $notes)
                                    .frame(height: 100)
                                    .padding(4)

                                if notes.isEmpty {
                                    Text("Enter additional information...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 12)
                                        .padding(.leading, 9)
                                        .allowsHitTesting(false)
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCheckIn()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert(isPresented: $showingSaveAlert) {
                Alert(
                    title: Text(saveSuccess ? "Success!" : "Error"),
                    message: Text(saveSuccess ? "Your check-in has been saved." : "There was an error saving your check-in."),
                    dismissButton: .default(Text("OK")) {
                        if saveSuccess {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
            .sheet(item: $activePopup) { popupType in
                CheckInDetailPopupView(
                    sleepQuality: $sleepQuality,
                    sleepHours: $sleepHours,
                    selectedSymptoms: $selectedSymptoms,
                    selectedFactors: $selectedFactors,
                    didEnterSleep: $didEnterSleep,
                    type: popupType
                )
            }
        }
    }
    
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var moodDescription: String {
        switch mood {
        case 1: return "Awful"
        case 2: return "Not Great"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great"
        default: return ""
        }
    }
    
    private var isFormValid: Bool {
        // Add any additional validation here
        return true
    }
    
    private func saveCheckIn() {
        // In a real app, you would save this data to your database
        // For now, we'll just show a success message
        saveSuccess = true
        showingSaveAlert = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This would be where you handle the actual save to your database
            print("Saving check-in data:", [
                "date": selectedDate,
                "mood": mood,
                "moodEmoji": moodEmojis[mood - 1],
                "sleepQuality": sleepQuality,
                "sleepHours": sleepHours,
                "stressLevel": stressLevel,
                "symptoms": Array(selectedSymptoms),
                "environmentalFactors": Array(selectedFactors),
                "notes": notes
            ])
        }
    }
}

// Helper view for multi-selection
struct MultiSelectionView: View {
    let items: [String]
    @Binding var selectedItems: Set<String>
    let title: String
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    if selectedItems.contains(item) {
                        selectedItems.remove(item)
                    } else {
                        selectedItems.insert(item)
                    }
                }) {
                    HStack {
                        Text(item)
                        Spacer()
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle(title)
    }
}

struct CheckInView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckInView(selectedSymptoms: .constant(["Headache"]), selectedFactors: .constant(["Stress"]))
        }
    }
}

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    var accentColor: Color = Color(red: 48/255, green: 181/255, blue: 255/255) // #30B5FF

    var body: some View {
        HStack {
            Text("Date").font(.headline)
            Spacer()
            DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
            Image(systemName: "calendar").foregroundColor(accentColor)
        }
        .padding(.vertical, 5)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct DetailActionButton: View {
    var isEditMode: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isEditMode ? "pencil.circle.fill" : "plus.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - CheckInDetailPopupView

struct CheckInDetailPopupView: View {
    @Binding var sleepQuality: Double
    @Binding var sleepHours: Double
    @Binding var selectedSymptoms: Set<String>
    @Binding var selectedFactors: Set<String>
    @Binding var didEnterSleep: Bool // NEW
    var type: CheckInDetailType

    @Environment(\.dismiss) var dismiss

    // Temporäre Werte zur Bearbeitung
    @State private var tempSleepQuality: Double = 5
    @State private var tempSleepHours: Double = 7
    @State private var tempSymptoms: Set<String> = []
    @State private var tempFactors: Set<String> = []
    @State private var noneSelected = false

    var body: some View {
        NavigationView {
            Form {
                switch type {
                case .sleep:
                    sleepSection
                case .body:
                    symptomsSection
                case .environment:
                    environmentSection
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        sleepQuality = tempSleepQuality
                        sleepHours = tempSleepHours
                        selectedSymptoms = tempSymptoms
                        selectedFactors = tempFactors
                        if type == .sleep {
                            didEnterSleep = true
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempSleepQuality = sleepQuality
                tempSleepHours = sleepHours
                tempSymptoms = selectedSymptoms
                tempFactors = selectedFactors
            }
        }
    }

    private var sleepSection: some View {
        Section(header: Text("How well did you sleep?")) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Quality: \(Int(tempSleepQuality))/10")
                    Slider(value: $tempSleepQuality, in: 1...10, step: 1)
                }

                VStack(alignment: .leading) {
                    Text("Hours Slept")
                    
                    let hours = Array(stride(from: 0.0, through: 12.0, by: 0.5))
                    
                    Picker("Hours Slept", selection: $tempSleepHours) {
                        ForEach(hours, id: \.self) { hour in
                            Text(String(format: "%.1f h", hour)).tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var symptomsSection: some View {
        let symptoms = ["Headache", "Nausea", "Sensitivity to Light", "Sensitivity to Sound", "Aura", "Neck Tension", "Pressure Behind Eyes", "Fatigue", "Blurred Vision", "Irritability"]

        return Group {
            Section(header: Text("Body Symptoms")) {
                ForEach(symptoms, id: \.self) { symptom in
                    MultipleSelectionRowPopup(title: symptom, isSelected: tempSymptoms.contains(symptom)) {
                        toggle(item: symptom, in: &tempSymptoms)
                        noneSelected = false
                    }
                }

                Toggle("No symptoms", isOn: $noneSelected)
                    .onChange(of: noneSelected) { newValue in
                        if newValue {
                            tempSymptoms.removeAll()
                        }
                    }
            }
        }
    }

    private var environmentSection: some View {
        let factors = ["Stress", "Weather Changes", "Lack of Sleep", "Certain Foods", "Hormonal Changes", "Vacation", "Work Trip ", "Dehydration", "Skipped Meals", "Screen Time", "Noise Exposure", "Poor Air Quality"]

        return Group {
            Section(header: Text("Environment")) {
                ForEach(factors, id: \.self) { factor in
                    MultipleSelectionRowPopup(title: factor, isSelected: tempFactors.contains(factor)) {
                        toggle(item: factor, in: &tempFactors)
                        noneSelected = false
                    }
                }

                Toggle("None of the above", isOn: $noneSelected)
                    .onChange(of: noneSelected) { newValue in
                        if newValue {
                            tempFactors.removeAll()
                        }
                    }
            }
        }
    }

    private func toggle<T: Hashable>(item: T, in set: inout Set<T>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }

    private var title: String {
        switch type {
        case .sleep: return "Sleep Details"
        case .body: return "Body Symptoms"
        case .environment: return "Environment"
        }
    }
}

private struct MultipleSelectionRowPopup: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
