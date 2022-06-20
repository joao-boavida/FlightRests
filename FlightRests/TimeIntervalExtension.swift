//
//  TimeIntervalExtension.swift
//  FlightRests
//
//  Created by Joao Boavida on 27/02/2021.
//

import Foundation

extension TimeInterval {

    /// A computed variable which formats a time interval as an HH:mm string.
    var HHmm: String {
        let seconds = Int(self)

        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        let minutes = formatter.string(from: NSNumber(value: (seconds % 3600) / 60)) ?? "??"
        formatter.minimumIntegerDigits = 1
        let hours = formatter.string(from: NSNumber(value: seconds/3600)) ?? "??"

        return hours + ":" + minutes
    }
}
