//
//  RestPlan.swift
//  FlightRests
//
//  Created by João Boavida on 30/06/2022.
//

import Foundation

struct RestPlan: Equatable {

    /// the default TimeZone for the rest plan, which can then be changed by the user for visualisation purposes
    var defaultTimeZone: TimeZone

    /// the rest periods in the rest plan
    var restPeriods: [AssignedRestPeriod]

    init(timeZone: TimeZone, restPeriods: [AssignedRestPeriod]) {
        self.defaultTimeZone = timeZone
        self.restPeriods = restPeriods
    }

    init(restPeriods: [AssignedRestPeriod]) {
        self.defaultTimeZone = TimeZone.current
        self.restPeriods = restPeriods
    }

    static let exampleEmpty = RestPlan(restPeriods: [])
    static let example1 = RestPlan(restPeriods: [.example1, .example2, .example1, .example2])
    static let example2 = RestPlan(restPeriods: [.example1, .example2])

}
