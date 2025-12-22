//
//  DateFormatter+Extensions.swift
//  Todo
//
//  Created by Yvaine on 2025/9/16.
//

import Foundation

extension DateFormatter {
    // For displaying dates only (e.g., grouping keys, planned dates)
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        // Use user's current calendar and timezone for display
        formatter.calendar = .current
        formatter.timeZone = .current
        return formatter
    }()
    
    // Request 2: Add a new formatter for deadlines that includes time
    static let yyyyMMddHHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        // Use user's current calendar and timezone for display
        formatter.calendar = .current
        formatter.timeZone = .current
        return formatter
    }()
}
