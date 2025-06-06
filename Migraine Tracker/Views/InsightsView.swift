import SwiftUI

struct InsightsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Insights")
                    .font(.largeTitle)
                    .foregroundColor(.cyan)
                    .padding()
                
                // Trigger Statistics
                VStack {
                    Text("Trigger Statistics")
                        .font(.headline)
                    
                    // Placeholder for radar chart
                    Text("Radar Chart Placeholder")
                        .padding()
                }
                .padding()
                
                // Time Progression Graph
                VStack {
                    Text("Time Progression")
                        .font(.headline)
                    
                    // Placeholder for time progression graph
                    Text("Graph Placeholder")
                        .padding()
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("Insights", displayMode: .inline)
        }
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
