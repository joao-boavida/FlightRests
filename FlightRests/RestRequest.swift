//
//  RestRequest.swift
//  FlightRests
//
//  Created by Joao Boavida on 02/03/2021.
//

import Foundation

struct RestRequest {
    let beginDate: Date
    let endDate: Date
    let unitLength: TimeInterval = 300  // minimum rest period division in seconds, usually 300s = 5 min
    let numberOfUsers: Int
    let numberOfPeriods: Int
    let minimumBreakUnits: Int
    let midFlightServiceUnits: Int = 0 // for cabin crew only
    let beforeLandingServiceUnits: Int = 0 // for cabin crew only
    let crewFunction: CrewFunction
    let timeZone: TimeZone
}
