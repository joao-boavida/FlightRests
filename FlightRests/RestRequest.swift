//
//  RestRequest.swift
//  FlightRests
//
//  Created by Joao Boavida on 02/03/2021.
//

import Foundation

struct RestRequest: Codable {
    let beginDate: Date
    let endDate: Date
    var unitLength: TimeInterval = 300  // minimum rest period division in seconds, usually 300s = 5 min
    let numberOfUsers: Int
    let numberOfPeriods: Int
    let minimumBreakUnits: Int
    var midFlightServiceUnits: Int = 0 // for cabin crew only
    var beforeLandingServiceUnits: Int = 0 // for cabin crew only
    let crewFunction: CrewFunction
    let timeZone: TimeZone

    static let exampleFc1 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 15).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 18).date!, numberOfUsers: 3, numberOfPeriods: 3, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent)

    static let exampleFc2 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 20, hour: 18).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 20, hour: 23).date!, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent)
}
