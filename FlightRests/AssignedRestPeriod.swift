//
//  AssignedRestPeriod.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import Foundation

struct AssignedRestPeriod {
    let owner: String
    let period: DateInterval

    static let example1 = AssignedRestPeriod(owner: "Pilot 1", period: DateInterval(start: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 15).date!, duration: 7200))

    static let example2 = AssignedRestPeriod(owner: "Pilot 2", period: DateInterval(start: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 10, hour: 04, minute: 30).date!, duration: 9600))
}
