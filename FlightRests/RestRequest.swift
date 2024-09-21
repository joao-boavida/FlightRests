//
//  RestRequest.swift
//  FlightRests
//
//  Created by Joao Boavida on 02/03/2021.
//

import Foundation

struct RestRequest: Codable, Hashable, Comparable, CustomDebugStringConvertible {
    static func < (lhs: RestRequest, rhs: RestRequest) -> Bool {
        lhs.creationDate < rhs.creationDate
    }

    // Checks if this request is a true duplicate, excluding the creationDate
    func isTrueDuplicateOf(_ element: RestRequest) -> Bool {
        return self.updateKey == element.updateKey
    }

    // Unique key that represents the state of the request, excluding creationDate
    var updateKey: String {
        let beginDateString = ISO8601DateFormatter().string(from: beginDate)
        let endDateString = ISO8601DateFormatter().string(from: endDate)
        let timeZoneIdentifier = timeZone.identifier
        return "\(beginDateString)-\(endDateString)-\(unitLength)-\(numberOfUsers)-\(numberOfPeriods)-\(minimumBreakUnits)-\(midFlightServiceUnits)-\(beforeLandingServiceUnits)-\(crewFunction.rawValue)-\(timeZoneIdentifier)-\(optimiseBreaks)"
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

    // Computed property for the debug description
    var debugDescription: String {
        """
        RestRequest:
        - Begin Date: \(beginDate)
        - End Date: \(endDate)
        - Unit Length: \(unitLength) seconds
        - Number of Users: \(numberOfUsers)
        - Number of Periods: \(numberOfPeriods)
        - Minimum Break Units: \(minimumBreakUnits)
        - Mid-Flight Service Units: \(midFlightServiceUnits)
        - Before Landing Service Units: \(beforeLandingServiceUnits)
        - Crew Function: \(crewFunction)
        - Time Zone: \(timeZone.identifier)
        - Optimise Breaks: \(optimiseBreaks)
        """
    }

    static let exampleFc1 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 15).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 2, day: 19, hour: 18).date!, numberOfUsers: 3, numberOfPeriods: 3, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: true)

    static let exampleFc2 = RestRequest(beginDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 7, day: 14, hour: 18).date!, endDate: DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2021, month: 7, day: 14, hour: 23).date!, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: false)

    static let exampleToday = RestRequest(beginDate: Date(), endDate: Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 6, to: Date())!, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: true)

    static let exampleYesterday = RestRequest(beginDate: Calendar.autoupdatingCurrent.date(byAdding: .day, value: -1, to: Date())!, endDate: Date(), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: .autoupdatingCurrent, optimiseBreaks: false)
}
