import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            // Dashboard Tab
            NavigationView {
                DashboardView()
                    .navigationTitle("Dashboard")
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            
            // Calendar Tab
            NavigationView {
                CalendarView()
                    .navigationTitle("Calendar")
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            
            // Check-In Tab
            NavigationView {
                CheckInView(selectedSymptoms: .constant([]), selectedFactors: .constant([]))
                    .navigationTitle("Check-In")
            }
            .tabItem {
                Label("Check-In", systemImage: "plus.circle.fill")
            }
            
            // Insights Tab
            NavigationView {
                InsightsView()
                    .navigationTitle("Insights")
            }
            .tabItem {
                Label("Insights", systemImage: "chart.bar.fill")
            }
            
            // Profile Tab
            NavigationView {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .accentColor(.cyan)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
