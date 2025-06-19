import SwiftUI

struct CalendarView: View {
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
                MonthCalendarView(selectedDate: $selectedDate, calendarScope: $calendarScope)
            case .day:
                DayCalendarView(selectedDate: $selectedDate)
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

    private let calendar = Calendar.current

    var body: some View {
        VStack {
            MonthNavigation(selectedDate: $selectedDate)

            let days = calendar.generateMonthDays(for: selectedDate)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(days, id: \.self) { date in
                    let type = entryType(for: date)
                    let isToday = calendar.isDateInToday(date)

                    VStack {
                        HStack {
                            ZStack {
                                if isToday {
                                    Circle()
                                        .fill(Color.cyan.opacity(0.2))
                                        .frame(width: 24, height: 24)
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

                        if type == .migraine {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                        } else {
                            Spacer().frame(height: 20) // damit Layout stabil bleibt
                        }

                        Spacer()
                    }
                    .frame(width: 44, height: 50)
                    .background(type == .checkIn ? Color.green.opacity(0.15) : Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 1)
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

    private func entryType(for date: Date) -> EntryType {
        let day = calendar.component(.day, from: date)
        if day % 10 == 0 {
            return .checkIn
        } else if day % 5 == 0 {
            return .migraine
        } else {
            return .none
        }
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
    private let calendar = Calendar.current

    var body: some View {
        VStack {
            DayNavigation(selectedDate: $selectedDate)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack {
                            Text("\(hour):00")
                                .font(.caption)
                                .frame(width: 50, alignment: .trailing)

                            Divider()

                            if hasEntry(on: selectedDate, hour: hour) {
                                entryDetail(for: hour)
                            }

                            Spacer()
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                    }
                }
            }
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
