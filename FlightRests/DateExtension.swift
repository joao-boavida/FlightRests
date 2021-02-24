//
//  DateExtension.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import Foundation

extension Date {
    func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
}
