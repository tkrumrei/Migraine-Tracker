import SwiftUI

// Enum for calendar view options
enum CalendarScope: String, CaseIterable, Identifiable {
    case month = "Month"
    case week = "Week"
    case day = "Day"
    
    var id: String { self.rawValue }
}

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var calendarScope: CalendarScope = .month
    
    var body: some View {
        VStack {
            // Picker to switch between Month and Week view
            Picker("View", selection: $calendarScope) {
                ForEach(CalendarScope.allCases) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Conditionally show the calendar view
            Group {
                switch calendarScope {
                case .month:
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                case .week:
                    WeekView(selectedDate: $selectedDate)
                case .day:
                    DayView(selectedDate: $selectedDate)
                }
            }
            .padding(.horizontal)
            
            // Events list will be populated here
            List {
                // Events will be listed here
            }
        }
        // .navigationTitle is handled by the NavigationView in MainTabView
    }
    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// Custom Week View
struct WeekView: View {
    @Binding var selectedDate: Date
    @State private var week: [Date] = []
    
    var body: some View {
        HStack {
            ForEach(week, id: \.self) { day in
                VStack {
                    Text(day.toString(format: "EEE").uppercased()) // E.g., "MON"
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(day.toString(format: "d")) // E.g., "13"
                        .fontWeight(isSameDay(day, selectedDate) ? .bold : .regular)
                        .foregroundColor(isSameDay(day, selectedDate) ? .white : .primary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(isSameDay(day, selectedDate) ? Color.cyan : Color.clear)
                        )
                }
                .onTapGesture {
                    selectedDate = day
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
        .onAppear(perform: setupWeek)
        .onChange(of: selectedDate) {
            setupWeek()
        }
    }
    
    private func setupWeek() {
        week = Calendar.current.getWeek(for: selectedDate)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

// Custom Day View
struct DayView: View {
    @Binding var selectedDate: Date
    
    private let timeSlots = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM",
                            "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header
            VStack(spacing: 4) {
                Text(selectedDate.toString(format: "EEEE, MMM d, yyyy"))
                    .font(.headline)
                
                // Navigation buttons
                HStack {
                    Button(action: { navigateDay(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Button("Today") {
                        selectedDate = Date()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: { navigateDay(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Time slots
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(timeSlots, id: \.self) { timeSlot in
                        HStack(alignment: .top, spacing: 0) {
                            Text(timeSlot)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 50, alignment: .trailing)
                                .padding(.trailing, 8)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.separator))
                                .padding(.vertical, 15)
                            
                            // Event placeholder - will be replaced with actual events
                            if timeSlot == "9 AM" {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(height: 60)
                                    .overlay(
                                        Text("Event")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(4)
                                        , alignment: .topLeading
                                    )
                                    .padding(.leading, 8)
                            }
                        }
                        .frame(height: 60)
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
    private func navigateDay(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// Helper extensions
extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Calendar {
    func getWeek(for date: Date) -> [Date] {
        guard let weekInterval = self.dateInterval(of: .weekOfYear, for: date) else { return [] }
        var week: [Date] = []
        for i in 0..<7 {
            if let day = self.date(byAdding: .day, value: i, to: weekInterval.start) {
                week.append(day)
            }
        }
        return week
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CalendarView()
        }
    }
}
