//
//  Data+Extensions.swift
//  Todo
//
//  Created by Yvaine on 2025/9/15.
//

import Foundation

// 为 Date 添加一个扩展，方便判断某个日期是否在另一个日期区间内
extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
