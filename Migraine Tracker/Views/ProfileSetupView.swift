import SwiftUI

struct ProfileSetupView: View {
    @State private var progress: Double = 0.0
    @State private var secondsRemaining = 5
    @Binding var showMainTabView: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("Setting up your")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Migraine Profile...")
                .font(.title)
                .fontWeight(.bold)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal, 40)

            Text("\(secondsRemaining) seconds remaining...")
                .foregroundColor(.gray)
                .font(.caption)

            Spacer()
        }
        .onAppear {
            startCountdown()
        }
    }

    func startCountdown() {
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                secondsRemaining = 5 - i
                progress = Double(i) / 5.0
                if i == 5 {
                    showMainTabView = true
                }
            }
        }
    }
}
