import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Sample data
    let riskLevel = 3
    let topTriggers = [
        (name: "Weather", percentage: 90),
        (name: "Noise", percentage: 85),
        (name: "Sleep", percentage: 63)
    ]
    
    let tipOfTheDay = "Today's migraine risk is slightly elevated. Try to keep your environment quiet and stay well-rested."
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Risk Level Card
                    VStack(spacing: 15) {
                        Text("Today's Risk")
                            .font(.headline)
                        
                        // Risk visualization
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { level in
                                Circle()
                                    .fill(level <= riskLevel ? Color.orange : Color.gray.opacity(0.3))
                                    .frame(width: 12, height: 12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Top Triggers
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Top Triggers")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(topTriggers.indices, id: \.self) { index in
                                HStack {
                                    Text("\(index + 1). \(topTriggers[index].name)")
                                    Spacer()
                                    Text("\(topTriggers[index].percentage)%")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Tip of the Day
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tip of the day")
                            .font(.headline)
                        
                        Text(tipOfTheDay)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Data for today
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Data for today")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("Temperature")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("25°C")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("UV-Index")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("3")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Humidity")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("47%")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Air Pressure")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("1005")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

// Nur EINE Preview Definition
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthViewModel())
    }
}
