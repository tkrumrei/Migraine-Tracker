import SwiftUI

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.cyan)
                
                Text("Export Data")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Export your migraine data to share with healthcare providers or for backup purposes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    exportData()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Data")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Export")
            .alert("Export Successful", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text("Successfully exported your migraine data!")
            }
        }
    }
    
    private func exportData() {
        // Simulate export process
        showingAlert = true
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        ExportView()
            .environmentObject(AuthViewModel())
    }
}