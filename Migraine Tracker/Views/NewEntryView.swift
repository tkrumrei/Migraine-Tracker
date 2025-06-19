import SwiftUI

struct NewEntryView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showDatePickerSheet = false
    @State private var selectedDate = Date()
    @State private var fromHour = Calendar.current.component(.hour, from: Date().addingTimeInterval(-60))
    @State private var fromMinute = Calendar.current.component(.minute, from: Date().addingTimeInterval(-60))
    @State private var toHour = Calendar.current.component(.hour, from: Date())
    @State private var toMinute = Calendar.current.component(.minute, from: Date())

    @State private var showFromSheet = false
    @State private var showToSheet = false
    @State private var selectedSymptoms: Set<String> = []
    @State private var customSymptoms: [String] = []
    @State private var customSymptom = ""
    @State private var painScale: Double = 5
    @State private var showLocationSearch = false
    @State private var location = ""
    @State private var notes = ""

    private let accentColor = Color(red: 48/255, green: 181/255, blue: 255/255)
    @State private var predefinedSymptoms = ["Nausea", "Aura", "Tension", "Cluster"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    dateTimeSection
                    symptomsSection
                    painScaleSection
                    locationSection
                    notesSection
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { presentationMode.wrappedValue.dismiss() }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveEntry() }
                }
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
    
    private var dateTimeSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 11) {
                // Date Row
                HStack {
                    Text("Date").font(.headline)
                    Spacer()
                    Button(action: { showDatePickerSheet = true }) {
                        Text(selectedDate, style: .date)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    }
                    Image(systemName: "calendar")
                        .foregroundColor(.cyan)
                }
                
                Divider()
                
                // Time Row
                HStack(alignment: .center) {
                    Text("Period").font(.headline)

                    Spacer()

                    HStack(spacing: 6) {
                        // From Time Button
                        Button(action: { showFromSheet = true }) {
                            Text("\(String(format: "%02d", fromHour)) : \(String(format: "%02d", fromMinute))")
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }

                        Text("-")

                        // To Time Button
                        Button(action: { showToSheet = true }) {
                            Text("\(String(format: "%02d", toHour)) : \(String(format: "%02d", toMinute))")
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        }
                    }

                    Image(systemName: "clock")
                        .foregroundColor(accentColor)
                }
            }
        }
        .sheet(isPresented: $showDatePickerSheet) {
            VStack(spacing: 20) {
                DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                Button("Done") {
                    showDatePickerSheet = false
                }
                .padding()
            }
            .presentationDetents([.medium])
        }
        // FROM TIME SHEET
        .sheet(isPresented: $showFromSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Start Time")
                        .font(.title2).bold()

                    HStack(spacing: 12) {
                        Picker("Hour", selection: $fromHour) {
                            ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()

                        Text(":")
                            .font(.title)

                        Picker("Minute", selection: $fromMinute) {
                            ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(height: 150)

                    Spacer()
                }
                .padding()
                .navigationTitle("From")
                .navigationBarItems(trailing: Button("Done") {
                    showFromSheet = false
                })
            }
        }

        // TO TIME SHEET
        .sheet(isPresented: $showToSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("End Time")
                        .font(.title2).bold()

                    HStack(spacing: 12) {
                        Picker("Hour", selection: $toHour) {
                            ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()

                        Text(":")
                            .font(.title)

                        Picker("Minute", selection: $toMinute) {
                            ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(height: 150)

                    Spacer()
                }
                .padding()
                .navigationTitle("Until")
                .navigationBarItems(trailing: Button("Done") {
                    showToSheet = false
                })
            }
        }
    }

    private var symptomsSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Symptoms").font(.headline)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), alignment: .leading),
                        GridItem(.flexible(), alignment: .leading)
                    ],
                    spacing: 12
                ) {
                    let maxCount = max(predefinedSymptoms.count, customSymptoms.count)
                    ForEach(0..<maxCount, id: \.self) { index in
                        // Linke Spalte
                        if index < predefinedSymptoms.count {
                            CheckboxView(
                                label: predefinedSymptoms[index],
                                accentColor: accentColor,
                                isChecked: selectedSymptoms.contains(predefinedSymptoms[index])
                            ) {
                                toggleSymptom(predefinedSymptoms[index])
                            }
                        } else {
                            Spacer()
                        }

                        // Rechte Spalte
                        if index < customSymptoms.count {
                            CheckboxView(
                                label: customSymptoms[index],
                                accentColor: accentColor,
                                isChecked: selectedSymptoms.contains(customSymptoms[index])
                            ) {
                                toggleSymptom(customSymptoms[index])
                            }
                        } else {
                            Spacer()
                        }
                    }
                }
                Divider()

                VStack {
                    HStack {
                        TextField("Add your own symptom...", text: $customSymptom)
                            .textInputAutocapitalization(.sentences)
                            .disableAutocorrection(true)

                        Button(action: addCustomSymptom) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .disabled(customSymptom.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(customSymptom.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
                    }
                    .padding(10)
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
            }
        }
    }
    
    private var painScaleSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Pain Scale").font(.headline)
                
                HStack {
                    Image(systemName: "bolt.heart")
                        .foregroundColor(.red)
                    Text("How strong is the pain?")
                    Spacer()
                    Text("\(Int(painScale))/10")
                        .foregroundColor(.secondary)
                }

                Slider(value: $painScale, in: 1...10, step: 1)
                    .accentColor(painScaleColor(for: painScale))

                HStack {
                    Text("No pain")
                    Spacer()
                    Text("Severe pain")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }

    private var locationSection: some View {
        sectionCard {
            HStack{
                VStack(alignment: .leading) {
                    Text("Location:").font(.headline)
                    TextField("Where did it happen?", text: $location)
                        .disabled(true) // Eingabe über Sheet
                }
                Button(action: {
                    showLocationSearch = true
                }) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color(.systemGray5)) // Hintergrund des Buttons
                        .cornerRadius(10) // Abgerundete Ecken
                        .overlay( // Rahmen
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                }
            }
        }
        .sheet(isPresented: $showLocationSearch) {
            LocationSearchView(selectedLocation: $location)
        }
    }

    private var notesSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Notes:").font(.headline)
                    Spacer()
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

    private func toggleSymptom(_ symptom: String) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    private func addCustomSymptom() {
        let trimmed = customSymptom.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !predefinedSymptoms.contains(trimmed),
              !customSymptoms.contains(trimmed) else { return }

        customSymptoms.append(trimmed)
        selectedSymptoms.insert(trimmed)
        customSymptom = ""
    }

    private func saveEntry() {
        // Save logic here
        presentationMode.wrappedValue.dismiss()
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

struct NewEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NewEntryView()
    }
}

struct LocationSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLocation: String
    @State private var searchText = ""
    @State private var savedLocations: [String] = ["Home", "Office", "Supermarket", "Gym", "Park"]

    var filteredResults: [String] {
        if searchText.isEmpty {
            return savedLocations
        } else {
            return savedLocations.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search or add location...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button(action: addNewLocation) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(searchText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                    }
                    .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                List {
                    ForEach(filteredResults, id: \.self) { location in
                        Button(action: {
                            selectedLocation = location
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(location)
                        }
                    }
                }
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func addNewLocation() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !savedLocations.contains(trimmed) else { return }
        savedLocations.append(trimmed)
        selectedLocation = trimmed
        presentationMode.wrappedValue.dismiss()
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
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? accentColor : .secondary)
                Text(label)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // ← Wichtig für linksbündig
        }
        .buttonStyle(PlainButtonStyle())
    }
}
