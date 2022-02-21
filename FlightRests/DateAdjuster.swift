//
//  DateAdjuster.swift
//  FlightRests
//
//  Created by João Boavida on 18/02/2022.
//

import Foundation

struct DateAdjuster {

    /// Adjusts the output date of a datepicker for the beginning of rests to match the day the user most likely wants to select according to the selected time and the present moment
    /// - Parameters:
    ///   - rawBeginDate: date obtained from the date picker
    ///   - referenceNow: optional parameter for testing, defaults to current date.
    /// - Returns: adjusted Date object
    static func adjustedBeginDate(_ rawBeginDate: Date, referenceNow: Date = Date()) -> Date {
        if rawBeginDate.timeIntervalSince(referenceNow) / 3600 < -6 { // in hours
            return Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1), to: rawBeginDate) ?? rawBeginDate
        } else if rawBeginDate.timeIntervalSince(referenceNow) / 3600 > 12 { // in hours
            return Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: -1), to: rawBeginDate) ?? rawBeginDate
        } else {
            return rawBeginDate
        }
    }

    /// Adjusts the output date of the end of rest datepickers to reflect the day the user most likely wants to select, based on the current date; also adjusts the end of the rest periods to account for cabin crew service.
    /// - Parameters:
    ///   - beginDate: corrected date at which rests begin
    ///   - rawEndDate: output from the end of rest datepicker (flight crew)
    ///   - rawLandingDate: output for the landing time datepicker (cabin crew)
    ///   - serviceTimeSeconds: number of seconds required for service (cabin crew)
    ///   - crewFunction: function
    ///   - referenceNow: optional parameter for testing, defaults to current date.
    /// - Returns: the end of rests date that will be fed to the calculator
    static func adjustedEndDate(_ beginDate: Date, _ rawEndDate: Date, _ rawLandingDate: Date, _ serviceTimeSeconds: Int, _ crewFunction: CrewFunction, referenceNow: Date = Date()) -> Date {
        switch crewFunction {
        case .flightCrew:
            return rawEndDate > beginDate ? rawEndDate : Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1), to: rawEndDate) ?? rawEndDate
        case .cabinCrew:
            var correctedDate = rawLandingDate > beginDate ? rawLandingDate : Calendar.autoupdatingCurrent.date(byAdding: DateComponents(day: 1), to: rawLandingDate) ?? rawLandingDate
            correctedDate.addTimeInterval(Double(-1 * serviceTimeSeconds)) // the adjustment must be negative as the end of the rests is before the beginning of the service
            return correctedDate
        }
    }
}
