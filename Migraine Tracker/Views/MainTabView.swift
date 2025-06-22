import SwiftUI

func calculateCheckInStreak(currentUser: AppUser?) -> Int {
    guard let user = currentUser,
          user.email == "test@30five.com" else {
        return 0
    }
    
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var streak = 0
    
    // Check consecutive days starting from today going backwards
    for offset in 0..<365 { // Check up to a year
        if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
            let dayStart = calendar.startOfDay(for: date)
            let events = getTestUserEvents(currentUser: user)[dayStart] ?? []
            let hasCheckIn = events.contains(where: { $0.type == .checkIn })
            
            if hasCheckIn {
                streak += 1
            } else {
                break // Streak broken
            }
        }
    }
    
    return streak
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    @State private var showingActionSheet = false
    @State private var showingCheckIn = false
    @State private var showingNewEntry = false
    
    // State for CheckInView bindings
    @State private var selectedSymptoms: Set<String> = []
    @State private var selectedFactors: Set<String> = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main TabView without the middle button
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                NavigationView {
                    DashboardView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack {
                                    Text("Dashboard")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                        Text("\(calculateCheckInStreak(currentUser: authViewModel.currentUser))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                }
                .tag(0)
                
                // Calendar Tab
                NavigationView {
                    CalendarView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack {
                                    Text("Calendar")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                        Text("\(calculateCheckInStreak(currentUser: authViewModel.currentUser))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                }
                .tag(1)
                
                // Empty view for the middle tab (invisible)
                Color.clear
                    .tag(2)
                
                // Insights Tab
                NavigationView {
                    InsightsView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack {
                                    Text("Insights")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                        Text("\(calculateCheckInStreak(currentUser: authViewModel.currentUser))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                }
                .tag(3)
                
                // Profile Tab
                NavigationView {
                    ProfileView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack {
                                    Text("Profile")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.orange)
                                            .font(.title2)
                                        Text("\(calculateCheckInStreak(currentUser: authViewModel.currentUser))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                }
                .tag(4)
            }
            .accentColor(.cyan)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                // Dashboard Button
                Button(action: { selectedTab = 0 }) {
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 22))
                        Text("Dashboard")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 0 ? .cyan : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Calendar Button
                Button(action: { selectedTab = 1 }) {
                    VStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 22))
                        Text("Calendar")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 1 ? .cyan : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Middle Button
                Button(action: { showingActionSheet = true }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                        Text("New")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 2 ? .cyan : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Insights Button
                Button(action: { selectedTab = 3 }) {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 22))
                        Text("Insights")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 3 ? .cyan : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Profile Button
                Button(action: { selectedTab = 4 }) {
                    VStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 22))
                        Text("Profile")
                            .font(.caption2)
                    }
                    .foregroundColor(selectedTab == 4 ? .cyan : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 60)
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.bottom))
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("New"),
                buttons: [
                    .default(Text("New Check-In")) {
                        // Reset state for a fresh check-in
                        selectedSymptoms = []
                        selectedFactors = []
                        showingCheckIn = true
                    },
                    .default(Text("New Entry")) {
                        showingNewEntry = true
                    },
                    .cancel()
                ]
            )
        }
        .fullScreenCover(isPresented: $showingCheckIn) {
            // CheckInView has its own NavigationView and dismiss logic
            CheckInView(selectedSymptoms: $selectedSymptoms, selectedFactors: $selectedFactors)
        }
        .fullScreenCover(isPresented: $showingNewEntry) {
            NewEntryView()
                .navigationTitle("New Entry")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(ThemeManager())
    }
}
