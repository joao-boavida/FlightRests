//
//  RestRequest.swift
//  FlightRests
//
//  Created by Joao Boavida on 02/03/2021.
//

import Foundation

struct RestRequest: Codable, Hashable, Comparable {
    static func < (lhs: RestRequest, rhs: RestRequest) -> Bool {
        lhs.creationDate < rhs.creationDate
    }

    func isTrueDuplicateOf (_ element: RestRequest) -> Bool {
        self.beginDate == element.beginDate && self.endDate == element.endDate && self.unitLength == element.unitLength && self.numberOfUsers == element.numberOfUsers && self.numberOfPeriods == element.numberOfPeriods && self.minimumBreakUnits == element.minimumBreakUnits && self.midFlightServiceUnits == element.midFlightServiceUnits && self.beforeLandingServiceUnits == element.beforeLandingServiceUnits && self.crewFunction == element.crewFunction && self.timeZone == element.timeZone
    }

    var creationDate: Date = Date()
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
    let optimiseBreaks: Bool

    static let exampleFc1 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 15).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 18).date!, numberOfUsers: 3, numberOfPeriods: 3, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: true)

    static let exampleFc2 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 7, day: 14, hour: 18).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 7, day: 14, hour: 23).date!, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: false)

    static let exampleToday = RestRequest(beginDate: Date(), endDate: Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 6, to: Date())!, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: true)

    static let exampleYesterday = RestRequest(beginDate: Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: Date())!, endDate: Date(), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: false)
}
