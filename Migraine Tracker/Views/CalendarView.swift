import SwiftUI

enum CalendarEventType {
    case checkIn
    case migraine
}

struct CalendarEvent {
    let type: CalendarEventType
    let startHour: Int
    let endHour: Int
    let symptoms: [String]?
    let painScale: Int?
    let location: String?
    let notes: String?
    
    init(type: CalendarEventType, startHour: Int, endHour: Int, symptoms: [String]? = nil, painScale: Int? = nil, location: String? = nil, notes: String? = nil) {
        self.type = type
        self.startHour = startHour
        self.endHour = endHour
        self.symptoms = symptoms
        self.painScale = painScale
        self.location = location
        self.notes = notes
    }
}


func getTestUserEvents(currentUser: AppUser?) -> [Date: [CalendarEvent]] {
    // Only show test data for test user
    guard let user = currentUser,
          user.email == "test@30five.com" else {
        return [:]
    }
    
    var dict = [Date: [CalendarEvent]]()
    let calendar = Calendar.current
    
    // Juni 3 – Migraine 14–17
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 3)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 14, endHour: 17, 
                         symptoms: ["Headache", "Nausea", "Light sensitivity"], 
                         painScale: 7, 
                         location: "Office", 
                         notes: "Started after lunch, stress from work meeting")
        ]
    }
    
    // Juni 7 – Migraine 9–12
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 7)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 9, endHour: 12, 
                         symptoms: ["Headache", "Dizziness", "Sound sensitivity"], 
                         painScale: 6, 
                         location: "Home", 
                         notes: "Weather change, low barometric pressure")
        ]
    }
    
    // Juni 10 – Migraine 6–8 (existing)
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 10)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 6, endHour: 8, 
                         symptoms: ["Headache", "Nausea", "Fatigue"], 
                         painScale: 9, 
                         location: "Home", 
                         notes: "Woke up with migraine, possible hormonal trigger")
        ]
    }
    
    // Juni 15 – Migraine 20–23
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 15)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 20, endHour: 23, 
                         symptoms: ["Headache", "Light sensitivity", "Neck pain"], 
                         painScale: 6, 
                         location: "Office", 
                         notes: "Long day at computer, eye strain trigger")
        ]
    }
    
    // Juni 19 – Migraine 11–15
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 19)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 11, endHour: 15, 
                         symptoms: ["Headache", "Nausea", "Vomiting", "Dizziness"], 
                         painScale: 9, 
                         location: "Shopping Mall", 
                         notes: "Severe attack, missed meals yesterday")
        ]
    }
    
    // Juni 23 – Migraine 16–19
    if let date = calendar.date(from: DateComponents(year: 2025, month: 6, day: 23)) {
        dict[date] = [
            CalendarEvent(type: .migraine, startHour: 16, endHour: 19, 
                         symptoms: ["Headache", "Sound sensitivity", "Fatigue"], 
                         painScale: 5, 
                         location: "Gym", 
                         notes: "Mild migraine, managed with rest and hydration")
        ]
    }
    
    // Check-Ins
    for offset in 0...7 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let dayStart = calendar.startOfDay(for: date)
                dict[dayStart, default: []].append(
                    CalendarEvent(type: .checkIn, startHour: 0, endHour: 0)
                )
            }
        }
    for offset in 9...11 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let dayStart = calendar.startOfDay(for: date)
                dict[dayStart, default: []].append(
                    CalendarEvent(type: .checkIn, startHour: 0, endHour: 0)
                )
            }
        }
    for offset in 14...18 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: Date()) {
                let dayStart = calendar.startOfDay(for: date)
                dict[dayStart, default: []].append(
                    CalendarEvent(type: .checkIn, startHour: 0, endHour: 0)
                )
            }
        }
    
    return dict
}




struct CalendarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedDate = Date()
    @State private var calendarScope: CalendarScope = .month
    
    var body: some View {
        VStack {
            Picker("View", selection: $calendarScope) {
                Text("Month").tag(CalendarScope.month)
                Text("Day").tag(CalendarScope.day)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch calendarScope {
            case .month:
                MonthCalendarView(selectedDate: $selectedDate, calendarScope: $calendarScope, currentUser: authViewModel.currentUser)
            case .day:
                DayCalendarView(selectedDate: $selectedDate, currentUser: authViewModel.currentUser)
            }
        }
        .padding(.bottom, 60)
    }
}

enum CalendarScope {
    case month, day
}


struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var calendarScope: CalendarScope
    let currentUser: AppUser?

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            MonthNavigation(selectedDate: $selectedDate)

            let days = calendar.generateMonthDays(for: selectedDate)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    let types = entryTypes(for: date)
                    let isToday = calendar.isDateInToday(date)

                    VStack {
                        HStack {
                            ZStack {
                                if isToday {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 20, height: 20)
                                }

                                Text("\(calendar.component(.day, from: date))")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top, 6)
                        .padding(.leading, 6)

                        Spacer()

                        if types.contains(.migraine) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        } else {
                            Spacer().frame(height: 20)
                        }

                        Spacer()
                    }
                    .frame(width: 44, height: 50)
                    .background(types.contains(.checkIn) ? Color.green.opacity(0.15) : Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .onTapGesture {
                        selectedDate = date
                        calendarScope = .day
                    }
                }
            }
            .padding()
            Spacer()
        }
    }

    enum EntryType {
        case checkIn
        case migraine
        case none
    }

    private func entryTypes(for date: Date) -> Set<CalendarEventType> {
        let cleanDate = calendar.startOfDay(for: date)
        let events = getTestUserEvents(currentUser: currentUser)[cleanDate] ?? []
        return Set(events.map { $0.type })
    }
}

struct MonthNavigation: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current

    var body: some View {
        HStack {
            Button(action: { moveMonth(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(selectedDate, formatter: monthYearFormatter).font(.headline)
            Spacer()
            Button(action: { moveMonth(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }

    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }
}

extension Calendar {
    func generateMonthDays(for date: Date) -> [Date] {
        guard let monthInterval = self.dateInterval(of: .month, for: date),
              let firstDay = self.date(from: dateComponents([.year, .month], from: monthInterval.start)) else {
            return []
        }

        var days: [Date] = []
        let range = self.range(of: .day, in: .month, for: firstDay) ?? 1..<31
        for day in range {
            if let date = self.date(bySetting: .day, value: day, of: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}


struct DayCalendarView: View {
    @Binding var selectedDate: Date
    let currentUser: AppUser?
    private let calendar = Calendar.current

    var body: some View {
        let cleanDate = calendar.startOfDay(for: selectedDate)
        let events = getTestUserEvents(currentUser: currentUser)[cleanDate] ?? []
        let migraine = events.first(where: { $0.type == .migraine })
        let hasCheckIn = events.contains(where: { $0.type == .checkIn })

        VStack {
            DayNavigation(selectedDate: $selectedDate)

            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { hour in
                            HStack {
                                Text("\(hour):00")
                                    .font(.caption)
                                    .frame(width: 50, alignment: .trailing)
                                Divider()
                                Spacer()
                            }
                            .frame(height: 50)
                            .padding(.horizontal)
                        }
                    }

                    if let migraine = migraine {
                        Rectangle()
                            .fill(Color.red.opacity(0.2))
                            .frame(height: CGFloat(migraine.endHour - migraine.startHour) * 50)
                            .overlay(
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                        Text("Migraine")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    
                                    if let painScale = migraine.painScale {
                                        Text("Pain: \(painScale)/10")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                    }
                                    
                                    if let location = migraine.location {
                                        Text("Location: \(location)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    if let symptoms = migraine.symptoms, !symptoms.isEmpty {
                                        Text("Symptoms: \(symptoms.prefix(2).joined(separator: ", "))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.leading, 60)
                                .padding(.top, 4)
                                .padding(.trailing, 8),
                                alignment: .topLeading
                            )
                            .offset(y: CGFloat(migraine.startHour) * 50)
                    }
                }
            }
            .background(hasCheckIn ? Color.green.opacity(0.05) : Color.clear)
        }
    }

    private func hasEntry(on date: Date, hour: Int) -> Bool {
        return hour % 6 == 0
    }

    private func entryDetail(for hour: Int) -> some View {
        HStack {
            Circle()
                .fill(hour % 12 == 0 ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            Text(hour % 12 == 0 ? "Check-in" : "Migraine")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.leading, 10)
    }
}

struct DayNavigation: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current

    var body: some View {
        HStack {
            Button(action: { moveDay(by: -1) }) {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(selectedDate, formatter: dayFormatter).font(.headline)
            Spacer()
            Button(action: { moveDay(by: 1) }) {
                Image(systemName: "chevron.right")
            }
        }
        .padding()
    }

    private func moveDay(by value: Int) {
        if let newDate = calendar.date(byAdding: .day, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }
}
