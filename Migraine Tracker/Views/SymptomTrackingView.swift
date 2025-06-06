import SwiftUI

struct SymptomTrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedSymptoms: Set<String>
    @Binding var isPresented: Bool
    
    let symptoms = ["Neck tension", "Pressure behind eyes", "Infection", "Headache", "Nausea", "Sensitivity to light", "Sensitivity to sound"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Symptoms")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Leave any item untouched if you're not sure. Tap to cycle through.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                
                // Selection List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(symptoms, id: \.self) { symptom in
                            SymptomRow(
                                title: symptom,
                                isSelected: selectedSymptoms.contains(symptom),
                                action: {
                                    if selectedSymptoms.contains(symptom) {
                                        selectedSymptoms.remove(symptom)
                                    } else {
                                        selectedSymptoms.insert(symptom)
                                    }
                                }
                            )
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding()
                }
                
                // Save Button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarTitle("Symptom Tracking", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Back") {
                    isPresented = false
                }
                .foregroundColor(.cyan)
            )
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

// Separate Row Component for Symptoms
struct SymptomRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .cyan : .gray)
                    .font(.system(size: 22))
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 16))
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct SymptomTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomTrackingView(selectedSymptoms: .constant(["Headache", "Nausea"]), isPresented: .constant(true))
    }
}
