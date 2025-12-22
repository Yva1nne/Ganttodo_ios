// MARK: - Views/Calendar/WidgetCalendarView.swift
import SwiftUI
import SwiftData
import WidgetKit // Ensure WidgetKit is imported

// A self-contained, display-only Calendar View specifically for Widgets.
struct WidgetCalendarView: View {
    let tasks: [Task]
    let monthDate: Date
    let family: WidgetFamily // Changed from supportedFamilies to single family
    
    private var weekCount: Int {
        // Determine the number of weeks based on the widget family
        return family == .systemLarge ? 6 : 3
    }

    // Use the unified date generator from Calendar+Extensions
    private var weeks: [[Date]] {
        let allWeeks = Calendar.current.generateDates(for: monthDate)
        // Take the appropriate number of weeks for the widget size
        return Array(allWeeks.prefix(weekCount))
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            weekdayHeader
            
            VStack(spacing: 1) {
                // Display the calculated weeks
                ForEach(weeks, id: \.self) { week in
                    WeekView(week: week, tasks: tasks, currentDate: monthDate, isInteractive: false)
                }
            }
            // Ensure Spacer takes up minimal space if weeks fill the view
            Spacer(minLength: 0)
        }
        .padding(10) // Add some padding around the entire widget content
    }

    // MARK: - Header Views & Helpers
    private var headerView: some View {
        HStack {
            Text(monthDate, formatter: monthYearFormatter)
                .font(.caption).fontWeight(.bold) // Consistent font
            Spacer()
        }
        .padding(.bottom, 4)
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol).font(.system(size: 10)).frame(maxWidth: .infinity) // Consistent font
            }
        }
        .padding(.bottom, 2)
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY年 M月"
        return formatter
    }
}


// Helper Array extension for chunking dates into weeks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
