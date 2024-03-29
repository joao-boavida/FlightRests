//
//  RestCalculator.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import Foundation

enum InputStatus: String {
    case valid, negativeInterval, tooSmallInterval, unsupportedCombination
}

struct RestCalculator {

    public static func validateInputs(from request: RestRequest) -> InputStatus {
        let roundedRestInterval = Self.roundRestInterval(beginDate: request.beginDate, endDate: request.endDate, unitLength: request.unitLength)

        let totalUnits = Self.calculateTotalUnits(in: roundedRestInterval, unitLength: request.unitLength)

        // end date must not precede begin date
        guard request.beginDate < request.endDate else { return .negativeInterval }

        if request.numberOfPeriods % 2 == 0 {
            // for an even number of rest periods the number of units must be at least the breaks plus 1 per rest period.
            guard totalUnits >= request.numberOfPeriods + request.minimumBreakUnits * (request.numberOfPeriods - 1) else { return .tooSmallInterval }
        } else {
            // for an odd number of rest periods the number of units must be the breaks plus twice the number of long periods times number of short periods
            let longPeriods = request.numberOfPeriods / 2
            let shortPeriods = longPeriods + 1
            guard totalUnits >= longPeriods * shortPeriods * 2 + request.minimumBreakUnits * (request.numberOfPeriods - 1) else { return .tooSmallInterval }
        }

        // uneven rest periods only implemented for 2 users
        if request.numberOfUsers % request.numberOfPeriods != 0 {
            guard request.numberOfUsers == 2 else { return .unsupportedCombination }
        }

        return .valid
    }

    public static func calculateRests(from request: RestRequest) -> [AssignedRestPeriod] {

        guard Self.validateInputs(from: request) == .valid else { return [] }

        let roundedRestInterval = Self.roundRestInterval(beginDate: request.beginDate, endDate: request.endDate, unitLength: request.unitLength)

        let totalUnits = Self.calculateTotalUnits(in: roundedRestInterval, unitLength: request.unitLength)

        let distributedUnits = Self.distributeRestPlanUnits(numberOfUsers: request.numberOfUsers, numberOfPeriods: request.numberOfPeriods, minimumBreakUnits: request.minimumBreakUnits, totalUnits: totalUnits, optimiseBreaks: request.optimiseBreaks)

        // confirm the distributer did not return an empty array

        guard !distributedUnits.isEmpty else { return []}

        let dates = Self.createRestPlanDates(restPlanUnits: distributedUnits, roundedRestInterval: roundedRestInterval)

        return Self.assignPilotsRemoveBreaks(crewFunction: request.crewFunction, restPlanDates: dates, numberOfUsers: request.numberOfUsers)
    }

    /// Splits a given interval into rest units of a given length.
    /// - Parameters:
    ///   - roundedRestInterval: interval to be divided; should be trimmed to be a multiple of the unitLength
    ///   - unitLength: the lenght of time in each rest unit
    /// - Returns: the number of units in the given interval
    static func calculateTotalUnits(in roundedRestInterval: DateInterval, unitLength: TimeInterval) -> Int {
        Int(roundedRestInterval.duration/unitLength)
    }

    /// Creates a DateInterval based on the given dates rounding it according to the given precision
    /// - Parameters:
    ///   - beginDate: earliest date for rest
    ///   - endDate: latest date for rest
    ///   - precision: precision, in seconds, of rounding.
    /// - Returns: a date interval with the begindate rounded up, and the enddate rounded down.
    static func roundRestInterval(beginDate: Date, endDate: Date, unitLength: TimeInterval) -> DateInterval {
        let roundedStartDate = beginDate.round(precision: unitLength, rule: .up)
        let roundedEndDate = endDate.round(precision: unitLength, rule: .down)
        if roundedStartDate < roundedEndDate {
            return DateInterval(start: beginDate.round(precision: unitLength, rule: .up), end: endDate.round(precision: unitLength, rule: .down))
        } else {
            return DateInterval(start: beginDate, duration: 0) // this interval will then be deemed unusable for rests.
        }
    }

    /// Distributes the given rest units
    /// - Parameters:
    ///   - numberOfPilots: number of pilots to distribute rests by
    ///   - numberOfPeriods: number of rest periods
    ///   - minimumBreakUnits: minimum length of the break periods in units
    ///   - totalUnits: total units available
    /// - Returns: an array of Ints representing the rest and break periods. index 0 and evens are rest periods, odd indices are break periods
    static func distributeRestPlanUnits(numberOfUsers: Int, numberOfPeriods: Int, minimumBreakUnits: Int, totalUnits: Int, optimiseBreaks: Bool) -> [Int] {

        let numberOfBreaks = numberOfPeriods - 1

        let maximumRestUnits = totalUnits - numberOfBreaks * minimumBreakUnits // max units allocated to rest periods, which may not be possible to do because of the number of periods

        if numberOfPeriods % numberOfUsers == 0 {
            let finalRestPeriod = maximumRestUnits / numberOfPeriods // number of units per rest period. division of Ints automatically rounds down.

            // initialisation of the variable to exist outside the scope of the if/else clause
            var finalBreakPeriod = 0

            if optimiseBreaks {
                // if the optimise option is selected then increase breaks if possible
                let remainingUnitsForBreaks = maximumRestUnits % numberOfPeriods // remaining units which can, if possible be allocated to increasing breaks

                let usableExtraUnitsForBreaks = remainingUnitsForBreaks / numberOfBreaks

                finalBreakPeriod = minimumBreakUnits + usableExtraUnitsForBreaks
            } else {
                // otherwise just make the final break equal to the minimum break
                finalBreakPeriod = minimumBreakUnits
            }

            return (0 ... (numberOfPeriods + numberOfBreaks - 1)).map {
                $0 % 2 == 0 ? finalRestPeriod : finalBreakPeriod
            }

        } else {

            // for now assume 2 pilots for uneven periods. rests may be slightly different in total duration here.

            guard numberOfUsers == 2 else { return [] }

            let numberofLongPeriods = numberOfPeriods / numberOfUsers
            let numberofShortPeriods = numberofLongPeriods + 1

            let restUnitsPerPilot = maximumRestUnits / numberOfUsers

            var remainingUnitsForBreaks = maximumRestUnits % numberOfUsers // will be incremented later

            let finalShortRestPeriod = restUnitsPerPilot / numberofShortPeriods
            let finalLongRestPeriod = restUnitsPerPilot / numberofLongPeriods

            remainingUnitsForBreaks += (restUnitsPerPilot % numberofLongPeriods + restUnitsPerPilot % numberofShortPeriods) // add any remaining units here

            let usableExtraUnitsForBreaks = remainingUnitsForBreaks / numberOfBreaks

            let finalBreakperiod = minimumBreakUnits + usableExtraUnitsForBreaks

            // 3 periods: s-b-L-b-s; 5 periods s-b-L-b-s-b-L-b-s

            return (0 ... (numberOfPeriods + numberOfBreaks - 1)).map {
                if $0 == 0 { // index is 0
                    return finalShortRestPeriod
                }
                if $0 % 4 == 0 { // index is non zero and divisible by 4: 4, 8
                    return finalShortRestPeriod
                }
                if $0 % 2 == 0 { // index is non zero, even and not divisible by 4: 2, 6, 10
                    return finalLongRestPeriod
                } else {
                    return finalBreakperiod
                }
            }
        }

    }

    /// Converts an array of rest and break periods to date intervals beginning in a given beginDate
    /// - Parameters:
    ///   - restPlanUnits: the array of time periods in units
    ///   - roundedBeginDate: begin date rounded up to unit length
    /// - Returns: an array of date intervals beginning at the given begin date and respecting the given restPlanUnits array.
    static func createRestPlanDates(restPlanUnits: [Int], roundedRestInterval: DateInterval) -> [DateInterval] {

        let restPlanTimeIntervals = restPlanUnits.map {
            TimeInterval(Double($0 * 300))
        }

        var restPlanDateIntervals = [DateInterval]()

        for counter in 0 ..< restPlanTimeIntervals.count {
            if counter == 0 {
                restPlanDateIntervals.append(DateInterval(start: roundedRestInterval.start, duration: restPlanTimeIntervals[counter]))
            } else {
                restPlanDateIntervals.append(DateInterval(start: restPlanDateIntervals[counter-1].end, duration: restPlanTimeIntervals[counter]))
            }
        }

        return restPlanDateIntervals

    }

    /// Assigns pilots to each rest period and removes breaks.
    /// - Parameters:
    ///   - restPlanDates: an array of date intervals with the rest and break periods
    ///   - numberOfPilots: number of pilots to rest
    /// - Returns: an array of AssignedRestPeriods with the rest periods correctly assigned to the pilots.
    static func assignPilotsRemoveBreaks(crewFunction: CrewFunction, restPlanDates: [DateInterval], numberOfUsers: Int) -> [AssignedRestPeriod] {

        let breaksRemoved = restPlanDates.enumerated().compactMap { (index, element) in
            index % 2 == 0 ? element : nil
        }

        return breaksRemoved.enumerated().map { (index, element) in
            AssignedRestPeriod(crewFunction: crewFunction, owner: index % numberOfUsers + 1, period: element)
        }

    }
}
