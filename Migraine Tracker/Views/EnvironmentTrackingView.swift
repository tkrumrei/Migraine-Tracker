import SwiftUI

struct EnvironmentTrackingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedFactors: Set<String>
    @Binding var isPresented: Bool
    
    let factors = [
        "Weather (Changes, temperature)",
        "Bright light/screen glare",
        "Noise/Volume",
        "Air quality/pollution",
        "Allergies",
        "Strong smells",
        "Travel/long drives",
        "Crowded spaces"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("External Triggers")
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
                        ForEach(factors, id: \.self) { factor in
                            EnvironmentFactorRow(
                                title: factor,
                                isSelected: selectedFactors.contains(factor),
                                action: {
                                    if selectedFactors.contains(factor) {
                                        selectedFactors.remove(factor)
                                    } else {
                                        selectedFactors.insert(factor)
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
            .navigationBarTitle("Environment", displayMode: .inline)
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

// Separate Row Component for Environment Factors
struct EnvironmentFactorRow: View {
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
