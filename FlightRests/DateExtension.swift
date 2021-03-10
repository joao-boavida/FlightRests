//
//  DateExtension.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import Foundation

extension Date {

    var shortFormatDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }

    var shortFormatTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }

    var shortFormatDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }

    var ddMMDate: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("dd/MM")
        return formatter.string(from: self)
    }

    var currentCalendarOneDayLater: Date? {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: self)
    }

    func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
}
