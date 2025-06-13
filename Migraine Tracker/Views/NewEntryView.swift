import SwiftUI
import UIKit

// MARK: - Main View
struct NewEntryView: View {
    // Environment
    @Environment(\.presentationMode) var presentationMode
    
    // State
    @State private var selectedDate = Date()
    @State private var selectedHour = Calendar.current.component(.hour, from: Date())
    @State private var selectedMinute = Calendar.current.component(.minute, from: Date())
    @State private var selectedSymptoms: Set<String> = []
    @State private var customSymptom = ""
    @State private var painScale: Double = 5
    @State private var location = ""
    @State private var notes = ""
    
    @State private var hasUnsavedChanges = false
    @State private var showConfirmationDialog = false

    // Constants
    private let accentColor = Color(red: 48/255, green: 181/255, blue: 255/255) // #30B5FF
    private let predefinedSymptoms = ["Dizziness", "Headache", "Nausea"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    dateSection
                    timeSection
                    symptomsSection
                    painScaleSection
                    locationSection
                    notesSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { handleBackButton() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveEntry() }
                        .disabled(!isFormValid())
                }
            }
            .alert(isPresented: $showConfirmationDialog) {
                Alert(
                    title: Text("Unsaved Changes"),
                    message: Text("Are you sure you want to discard your changes?"),
                    primaryButton: .destructive(Text("Discard")) { presentationMode.wrappedValue.dismiss() },
                    secondaryButton: .cancel()
                )
            }
            .onChange(of: formState) { _ in
                hasUnsavedChanges = true
            }
        }
    }
    
    // MARK: - Form State for Change Tracking
    private var formState: [AnyHashable] {
        [selectedDate, selectedHour, selectedMinute, Array(selectedSymptoms), customSymptom, painScale, location, notes]
    }

    // MARK: - View Sections
    private var dateSection: some View {
        HStack {
            Text("Date:").font(.headline)
            Spacer()
            DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .labelsHidden()
            Image(systemName: "calendar").foregroundColor(accentColor)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var timeSection: some View {
        HStack {
            Text("What time:").font(.headline)
            Spacer()
            Picker("Hour", selection: $selectedHour) {
                ForEach(0..<24) { Text(String(format: "%02d", $0)).tag($0) }
            }.pickerStyle(MenuPickerStyle())
            Text(":").font(.headline).padding(.horizontal, -4)
            Picker("Minute", selection: $selectedMinute) {
                ForEach(0..<60) { Text(String(format: "%02d", $0)).tag($0) }
            }.pickerStyle(MenuPickerStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptoms:").font(.headline)
            ForEach(predefinedSymptoms, id: \.self) { symptom in
                CheckboxView(label: symptom, accentColor: accentColor, isChecked: selectedSymptoms.contains(symptom)) {
                    toggleSymptom(symptom)
                }
            }
            Menu {
                Button("Vertigo", action: { toggleSymptom("Vertigo") })
                Button("Aura", action: { toggleSymptom("Aura") })
                Button("Sensitivity to Light", action: { toggleSymptom("Sensitivity to Light") })
            } label: {
                HStack {
                    Text("More symptoms")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            .foregroundColor(.primary)
            
            TextField("Add your own symptom...", text: $customSymptom, onCommit: addCustomSymptom)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
        }
    }
    
    private var painScaleSection: some View {
        VStack(alignment: .leading) {
            Text("Scale: \(Int(painScale))").font(.headline)
            Slider(value: $painScale, in: 1...10, step: 1) {
            } minimumValueLabel: {
                Text("1").font(.caption)
            } maximumValueLabel: {
                Text("10").font(.caption)
            }
            .accentColor(painScaleColor(for: painScale))
            .onChange(of: painScale) { _ in
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading) {
            Text("Location:").font(.headline)
            HStack {
                TextField("Where did it happen?", text: $location)
                Image(systemName: "mappin.and.ellipse").foregroundColor(accentColor)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes:").font(.headline)
            TextEditor(text: $notes)
                .frame(minHeight: 100)
                .padding(4)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
        }
    }

    // MARK: - Functions
    private func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
    
    private func addCustomSymptom() {
        let trimmedSymptom = customSymptom.trimmingCharacters(in: .whitespaces)
        if !trimmedSymptom.isEmpty {
            selectedSymptoms.insert(trimmedSymptom)
            customSymptom = ""
        }
    }
    
    private func handleBackButton() {
        if hasUnsavedChanges {
            showConfirmationDialog = true
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func saveEntry() {
        // Placeholder for Core Data saving logic
        print("Entry saved!")
        hasUnsavedChanges = false
        presentationMode.wrappedValue.dismiss()
    }
    
    private func isFormValid() -> Bool {
        return painScale > 0 // Date is always valid
    }
    
    private func painScaleColor(for value: Double) -> Color {
        switch value {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...10: return .red
        default: return .gray
        }
    }
}

// MARK: - Checkbox Helper View
struct CheckboxView: View {
    let label: String
    let accentColor: Color
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring()) { action() }
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? accentColor : .secondary)
                Text(label).foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct NewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewEntryView()
    }
}
