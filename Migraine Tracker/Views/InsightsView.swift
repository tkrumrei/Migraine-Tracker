import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    // Only show insights for test user with data
                    if authViewModel.currentUser?.email == "test@30five.com" {
                        migraineSummaryCard
                        painScaleChart
                        symptomsAnalysis
                        locationAnalysis
                        timePatternAnalysis
                    } else {
                        noDataView
                    }
                }
                .padding(.bottom, 80)
            }
            .navigationTitle("Insights")
        }
    }
    
    private var migraineSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("June 2025 Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.top, 5)
            
            HStack(spacing: 45) {
                VStack(alignment: .leading) {
                    Text("6")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Total Attacks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("7")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Avg Pain Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("16h")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var painScaleChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pain Scale Over Time")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            let painData = [
                (date: "Jun 3", pain: 7),
                (date: "Jun 7", pain: 6),
                (date: "Jun 10", pain: 9),
                (date: "Jun 15", pain: 6),
                (date: "Jun 19", pain: 9),
                (date: "Jun 23", pain: 5)
            ]
            
            Chart(painData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Pain", item.pain)
                )
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Pain", item.pain)
                )
                .foregroundStyle(.red)
            }
            .frame(height: 150)
            .chartYScale(domain: 0...10)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var symptomsAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Common Symptoms")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            let symptomData = [
                ("Headache", 6, Color.red),
                ("Nausea", 3, Color.orange),
                ("Light sensitivity", 2, Color.yellow),
                ("Sound sensitivity", 2, Color.green),
                ("Fatigue", 2, Color.blue),
                ("Dizziness", 2, Color.purple)
            ]
            
            VStack(spacing: 8) {
                ForEach(symptomData, id: \.0) { symptom, count, color in
                    HStack {
                        Text(symptom)
                            .font(.body)
                        Spacer()
                        Text("\(count)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                        
                        Rectangle()
                            .fill(color.opacity(0.3))
                            .frame(width: CGFloat(count) * 15, height: 20)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var locationAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location Patterns")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            let locationData = [
                ("Home", 2, Color.blue),
                ("Office", 2, Color.orange),
                ("Shopping Mall", 1, Color.red),
                ("Gym", 1, Color.green)
            ]
            
            VStack(spacing: 8) {
                ForEach(locationData, id: \.0) { location, count, color in
                    HStack {
                        Text(location)
                            .font(.body)
                        Spacer()
                        Text("\(count)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                        
                        Rectangle()
                            .fill(color.opacity(0.3))
                            .frame(width: CGFloat(count) * 25, height: 20)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var timePatternAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time of Day Patterns")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            let timeData = [
                ("Morning (6-12)", 2, Color.orange),
                ("Afternoon (12-18)", 2, Color.yellow),
                ("Evening (18-24)", 2, Color.purple)
            ]
            
            VStack(spacing: 8) {
                ForEach(timeData, id: \.0) { timeRange, count, color in
                    HStack {
                        Text(timeRange)
                            .font(.body)
                        Spacer()
                        Text("\(count)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                        
                        Rectangle()
                            .fill(color.opacity(0.3))
                            .frame(width: CGFloat(count) * 25, height: 20)
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Location Insights:")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("• Most migraines occur at Home and Office")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Text("• Consider environmental factors like air quality, lighting, and stress levels in these locations")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    private var noDataView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Data Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Start tracking your migraines to see personalized insights and patterns.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 80)
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
