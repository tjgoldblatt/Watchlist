//
//  Date+EXT.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 7/25/23.
//

import Foundation

extension Date {
    func isWithinLastSevenDays() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now)
        return self >= (sevenDaysAgo ?? now)
    }
}
