//
//  RestCalculator.swift
//  FlightRests
//
//  Created by Joao Boavida on 24/02/2021.
//

import Foundation

struct RestCalculator {

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
    static func roundRestInterval(beginDate: Date, endDate: Date, precision: TimeInterval) -> DateInterval {
        DateInterval(start: beginDate.round(precision: precision, rule: .up), end: endDate.round(precision: precision, rule: .down))
    }

    /// Distributes the given rest units
    /// - Parameters:
    ///   - numberOfPilots: number of pilots to distribute rests by
    ///   - numberOfPeriods: number of rest periods
    ///   - minimumBreakUnits: minimum length of the break periods in units
    ///   - totalUnits: total units available
    /// - Returns: an array of Ints representing the rest and break periods. index 0 and evens are rest periods, odd indices are break periods
    static func distributeRestPlanUnits(numberOfPilots: Int, numberOfPeriods: Int, minimumBreakUnits: Int, totalUnits: Int) -> [Int] {

        let numberOfBreaks = numberOfPeriods - 1

        let maximumRestUnits = totalUnits - numberOfBreaks * minimumBreakUnits // max units allocated to rest periods, which may not be possible to do because of the number of periods

        if numberOfPilots % numberOfPeriods == 0 {
            let finalRestPeriod = maximumRestUnits / numberOfPeriods // number of units per rest period. division of Ints automatically rounds down.

            let remainingUnitsForBreaks = maximumRestUnits % numberOfPeriods // remaining units which can, if possible be allocated to increasing breaks

            let usableExtraUnitsForBreaks = remainingUnitsForBreaks / numberOfBreaks

            let finalBreakPeriod = minimumBreakUnits + usableExtraUnitsForBreaks

            return Array(repeating: 0, count: numberOfPeriods + numberOfBreaks).enumerated().map { (index, _) in
                index % 2 == 0 ? finalRestPeriod : finalBreakPeriod
            }

        } else {

            // for now assume 2 pilots for uneven periods. rests may be slightly different in total duration here.

            guard numberOfPilots == 2 else { fatalError("only implemented uneven rest periods for 2 pilots") }

            let numberofLongPeriods = numberOfPeriods / numberOfPilots
            let numberofShortPeriods = numberofLongPeriods + 1

            let restUnitsPerPilot = maximumRestUnits / numberOfPilots

            var remainingUnitsForBreaks = maximumRestUnits % numberOfPilots // will be incremented later

            let finalShortRestPeriod = restUnitsPerPilot / numberofShortPeriods
            let finalLongRestPeriod = restUnitsPerPilot / numberofLongPeriods

            remainingUnitsForBreaks += (restUnitsPerPilot % numberofLongPeriods + restUnitsPerPilot % numberofShortPeriods) // add any remaining units here

            let usableExtraUnitsForBreaks = remainingUnitsForBreaks / numberOfBreaks

            let finalBreakperiod = minimumBreakUnits + usableExtraUnitsForBreaks

            // 3 periods: s-b-L-b-s; 5 periods s-b-L-b-s-b-L-b-s

            return Array(repeating: 0, count: numberOfPeriods + numberOfBreaks).enumerated().map { (index, _) -> Int in
                if index == 0 { // index is 0
                    return finalShortRestPeriod
                }
                if index % 4 == 0 { // index is non zero and divisible by 4: 4, 8
                    return finalShortRestPeriod
                }
                if index % 2 == 0 { // index is non zero, even and not divisible by 4: 2, 6, 10
                    return finalLongRestPeriod
                } else {
                    return finalBreakperiod
                }

                /*if index % 2 == 0 { // index is even and non zero: 2, 4, 6, 8, 10
                    if index % 4 == 0 { // index is non zero and divisible by 4: 4, 8
                        return finalShortRestPeriod
                    } else { // index is non zero, even and not divisible by 4: 2, 6, 10
                        return finalLongRestPeriod
                    }
                } else {
                    return finalBreakperiod
                }*/
            }
        }

    }

    /// Converts an array of rest and break periods to date intervals beginning in a given beginDate
    /// - Parameters:
    ///   - restPlanUnits: the array of time periods in units
    ///   - roundedBeginDate: begin date rounded up to unit length
    /// - Returns: an array of date intervals beginning at the given begin date and respecting the given restPlanUnits array.
    static func createRestPlanDates(restPlanUnits: [Int], roundedBeginDate: Date) -> [DateInterval] {
        let restPlanTimeIntervals = restPlanUnits.map {
            TimeInterval(Double($0 * 300))
        }

        var restPlanDateIntervals = [DateInterval]()

        for counter in 0 ..< restPlanTimeIntervals.count {
            if counter == 0 {
                restPlanDateIntervals.append(DateInterval(start: roundedBeginDate, duration: restPlanTimeIntervals[counter]))
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
    static func assignPilotsRemoveBreaks(restPlanDates: [DateInterval], numberOfPilots: Int) -> [AssignedRestPeriod] {

        let breaksRemoved = restPlanDates.enumerated().compactMap { (index, element) in
            index % 2 == 0 ? element : nil
        }

        return breaksRemoved.enumerated().map { (index, element) in
            AssignedRestPeriod(owner: "Pilot #\(index % numberOfPilots + 1)", period: element)
        }

    }
}
