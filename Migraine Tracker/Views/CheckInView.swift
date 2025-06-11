import SwiftUI

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
    @State private var isSymptomTrackingPresented = false
    @State private var isEnvironmentTrackingPresented = false
    
    // Sample symptoms and environmental factors
    @Binding var selectedSymptoms: Set<String>
    @Binding var selectedFactors: Set<String>
    
    let symptoms = ["Headache", "Nausea", "Sensitivity to Light", "Sensitivity to Sound", "Aura"]
    let environmentalFactors = ["Stress", "Weather Changes", "Lack of Sleep", "Certain Foods", "Hormonal Changes"]
    
    // Mood emojis in order: 😭🙁😐🙂😁
    let moodEmojis = ["😭", "🙁", "😐", "🙂", "😁"]
    
    var body: some View {
        NavigationView {
            Form {
                // Date Section
                Section(header: Text("Date").font(.headline)) {
                    DatePicker("Select date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                }
                
                // Mood Section with Emojis
                Section(header: Text("How are you feeling?").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.blue)
                            Text("Mood")
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
                        .padding(.vertical, 5)
                    }
                }
                
                // Sleep Section
                Section(header: Text("Sleep").font(.headline)) {
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "moon.zzz")
                                    .foregroundColor(.purple)
                                Text("Sleep Quality: \(Int(sleepQuality))/10")
                            }
                            Slider(value: $sleepQuality, in: 1...10, step: 1)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.purple)
                                Text("Hours Slept: \(sleepHours, specifier: "%.1f") hours")
                            }
                            Slider(value: $sleepHours, in: 0...12, step: 0.5)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                // Stress Section
                Section(header: Text("Stress Level").font(.headline)) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.orange)
                            Text("How stressed do you feel?")
                            Spacer()
                            Text("\(Int(stressLevel))/10")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 5) {
                            Slider(value: $stressLevel, in: 1...10, step: 1)
                        }
                        
                        HStack {
                            Text("Relaxed")
                            Spacer()
                            Text("Stressed")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                
                // Symptoms & Environment Section
                Section(header: Text("Symptoms & Triggers").font(.headline)) {
                    // Symptoms
                    NavigationLink(destination: SymptomTrackingView(selectedSymptoms: $selectedSymptoms, isPresented: Binding(get: { isSymptomTrackingPresented }, set: { isSymptomTrackingPresented = $0 }))) {
                        Text("Select Symptoms")
                            .foregroundColor(selectedSymptoms.isEmpty ? .gray : .primary)
                    }

                    // Environmental Factors
                    NavigationLink(destination: EnvironmentTrackingView(selectedFactors: $selectedFactors, isPresented: Binding(get: { isEnvironmentTrackingPresented }, set: { isEnvironmentTrackingPresented = $0 }))) {
                        Text("Select Environmental Factors")
                            .foregroundColor(selectedFactors.isEmpty ? .gray : .primary)
                    }
                }
                
                // Notes Section
                Section(header: Text("Notes").font(.headline)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                            Text("Additional Notes")
                        }
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.top, 5)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Daily Check-In")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
        }
    }
    
    private var moodDescription: String {
        switch mood {
        case 1: return "Awful"
        case 2: return "Not Great"
        case 3: return "Okay"
        case 4: return "Good"
        case 5: return "Great!"
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
