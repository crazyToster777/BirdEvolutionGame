import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var game: BirdEvolutionGameViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                monthHeader
                weekdayHeaders
                calendarGrid
                selectedDateInfo
                Spacer()
            }
            .padding()
            .navigationTitle("Game Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private var weekdayHeaders: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDate(date, inSameDayAs: Date()),
                        dayStats: game.getDayStats(for: date)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                } else {
                    Text("")
                        .frame(height: 40)
                }
            }
        }
    }
    
    private var selectedDateInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedDateString)
                .font(.headline)
            
            if let stats = game.getDayStats(for: selectedDate), stats.totalGames > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Games played:")
                        Spacer()
                        Text("\(stats.totalGames)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Best score:")
                        Spacer()
                        Text("\(stats.bestScore)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Best tile:")
                        Spacer()
                        Text("\(stats.bestTile)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Total moves:")
                        Spacer()
                        Text("\(stats.totalMoves)")
                            .fontWeight(.medium)
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            } else {
                Text("No games played on this day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: currentMonth)
    }
    
    private var selectedDateString: String {
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private var weekdaySymbols: [String] {
        calendar.shortWeekdaySymbols
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthStart = calendar.dateInterval(of: .month, for: currentMonth)?.start else {
            return []
        }
        
        let monthEnd = monthInterval.end
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingDays = firstWeekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: leadingDays)
        
        var date = monthStart
        while date < monthEnd {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return days
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let dayStats: DayStats?
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 40, height: 40)
            
            if let stats = dayStats, stats.totalGames > 0 {
                Circle()
                    .stroke(activityColor, lineWidth: 2)
                    .frame(width: 44, height: 44)
            }
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.3)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    private var activityColor: Color {
        guard let stats = dayStats else { return .clear }
        
        if stats.totalGames >= 10 {
            return .green
        } else if stats.totalGames >= 5 {
            return .orange
        } else if stats.totalGames > 0 {
            return .yellow
        } else {
            return .clear
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(BirdEvolutionGameViewModel())
}
