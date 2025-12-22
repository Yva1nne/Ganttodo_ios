//
//  Calendar+Extensions.swift
//  Todo
//
//  Created by Yvaine on 2025/9/16.
//

import Foundation

extension Calendar {
    func isDateInThisYear(_ date: Date) -> Bool { isDate(date, equalTo: Date(), toGranularity: .year) }
    func isDateInThisMonth(_ date: Date) -> Bool { isDate(date, equalTo: Date(), toGranularity: .month) }
    func isDateInThisWeek(_ date: Date) -> Bool { isDate(date, equalTo: Date(), toGranularity: .weekOfYear) }

    // MARK: - Final Robust Month Grid Generator (Variable Weeks)
    func generateDates(for month: Date) -> [[Date]] {
        // 1. Get the interval for the entire month
        guard let monthInterval = self.dateInterval(of: .month, for: month) else {
            return []
        }
        let firstDayOfMonth = monthInterval.start
        
        // Find the last day of the month by going to the next month and subtracting one day
        guard let firstOfNextMonth = self.date(byAdding: .month, value: 1, to: firstDayOfMonth),
              let lastDayOfMonth = self.date(byAdding: .day, value: -1, to: firstOfNextMonth) else {
            return []
        }

        // 2. Find the first day of the week containing the first day of the month
        guard let firstDayOfFirstWeek = self.dateInterval(of: .weekOfMonth, for: firstDayOfMonth)?.start else {
            return []
        }

        // 3. Find the last day of the week containing the last day of the month
        guard let lastDayOfLastWeekInterval = self.dateInterval(of: .weekOfMonth, for: lastDayOfMonth),
              // dateInterval end is exclusive, so add 6 days to the start of the last week interval
              let lastDayOfGrid = self.date(byAdding: .day, value: 6, to: lastDayOfLastWeekInterval.start) else {
            return []
        }

        // 4. Generate all dates from the start of the first week to the end of the last week
        var allDays: [Date] = []
        var currentDate = firstDayOfFirstWeek
        while currentDate <= lastDayOfGrid {
            allDays.append(currentDate)
            guard let nextDay = self.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }

        // 5. Chunk into arrays of 7 days each
        guard !allDays.isEmpty else { return [] }
        
        var weeks: [[Date]] = []
        let daysPerWeek = 7
        let totalDays = allDays.count
        let weekCount = (totalDays + daysPerWeek - 1) / daysPerWeek // Calculate number of weeks needed
        
        for weekIndex in 0..<weekCount {
            let startIndex = weekIndex * daysPerWeek
            let endIndex = min(startIndex + daysPerWeek, totalDays)
            if startIndex < endIndex { // Ensure we don't create empty weeks
                 weeks.append(Array(allDays[startIndex..<endIndex]))
            }
        }
        
        // Ensure the last week always has 7 days (pad if necessary, though unlikely with this logic)
        if var lastWeek = weeks.last, lastWeek.count < 7, let lastDate = lastWeek.last {
             for i in 1...(7 - lastWeek.count) {
                 if let nextDate = self.date(byAdding: .day, value: i, to: lastDate) {
                     lastWeek.append(nextDate)
                 }
             }
             weeks[weeks.count - 1] = lastWeek
        }

        return weeks
    }
}
