//
//  FlightRestsTests.swift
//  FlightRestsTests
//
//  Created by Joao Boavida on 24/02/2021.
//

import XCTest
@testable import FlightRests

class FlightRestsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// checks a given distribution of rest units is fair and optimal
    /// - Parameters:
    ///   - result: the results to be analysed
    ///   - numberOfPeriods: number of rest periods
    ///   - totalUnits: number of total rest units
    ///   - numberOfUsers: number of users
    fileprivate func checkDistributedRestUnits(_ result: [Int], _ numberOfPeriods: Int, _ totalUnits: Int, _ numberOfUsers: Int) {
        let totalResultUnits = result.reduce(0, +)
        let numberOfBreaks = numberOfPeriods - 1

        let unusedUnits = totalUnits - totalResultUnits

        // the number of unused units must be less thant the number of breaks, otherwise further break optimisation is possible
        XCTAssertLessThan(unusedUnits, numberOfBreaks, "There are unused units which could be used to increment rests or breaks, \(numberOfUsers) users,  \(numberOfPeriods) rest periods")

        let restUnits = result.enumerated().compactMap {
            $0.offset % 2 == 0 ? $0.element : nil
        }

        XCTAssertTrue(numberOfUsers == 2 || numberOfUsers == 3, "Unsupported number of users")

        if numberOfUsers == 2 {
            // check for fair distribution 2 users
            let user1 = restUnits.enumerated().compactMap {
                $0.offset % 2 == 0 ? $0.element : nil
            }
            let totalUser1 = user1.reduce(0, +)
            let user2 = restUnits.enumerated().compactMap {
                $0.offset % 2 == 1 ? $0.element : nil
            }
            let totalUser2 = user2.reduce(0, +)
            XCTAssertEqual(totalUser1, totalUser2, "Unfair distribution of rest periods, \(numberOfUsers) users,  \(numberOfPeriods) rest periods")
        } else {
            // 3 rest periods for sure
            XCTAssertEqual(restUnits[0], restUnits[1], "Unfair distribution of rest periods, \(numberOfUsers) users,  \(numberOfPeriods) rest periods")
            XCTAssertEqual(restUnits[0], restUnits[2], "Unfair distribution of rest periods, \(numberOfUsers) users,  \(numberOfPeriods) rest periods")
        }
    }

    /// Tests if the distribution of rest units is being fair and optimised for several user/period cases.
    func testDistributeRestUnits() {
        let minimumBreakUnits = 1
        let totalUnits = 30

        var numberOfUsers = 2

        let optimiseBreaks = true

        for numberOfPeriods in 2 ... 4 {
            let result = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: numberOfPeriods, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits, optimiseBreaks: optimiseBreaks)

            checkDistributedRestUnits(result, numberOfPeriods, totalUnits, numberOfUsers)
        }

        numberOfUsers = 3

        let result = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: 3, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits, optimiseBreaks: optimiseBreaks)

        checkDistributedRestUnits(result, 3, totalUnits, numberOfUsers)

    }

    /// Test if the optimise breaks option is working properly
    func testOptimiseBreaksOption() {
        let minimumBreakUnits = 1
        let totalUnits = 22
        let numberOfUsers = 3
        let numberOfPeriods = 3

        var optimiseBreaks = false

        let result1 = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: numberOfPeriods, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits, optimiseBreaks: optimiseBreaks)

        XCTAssertEqual(result1[1], 1)

        optimiseBreaks = true

        let result2 = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: numberOfPeriods, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits, optimiseBreaks: optimiseBreaks)

        XCTAssertEqual(result2[1], 2)
    }

    func testRequestLogCleanUP() {

        let requestLog = RequestLog(testLog: true)

        // testing the removal of old entries

        let oldDate = DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2000, month: 11, day: 19).date!
        let oldRequest = RestRequest(creationDate: oldDate, beginDate: oldDate, endDate: oldDate, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 10, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!, optimiseBreaks: true)

        requestLog.addRequest(oldRequest)

        XCTAssertTrue(requestLog.requests.isEmpty)

        // testing the size trimming function
        for _ in 0 ... requestLog.maxEntries + 10 {
            let advance = Double(Int.random(in: -1000 ... 1000))
            let sampleRequest = RestRequest(beginDate: Date(timeIntervalSinceNow: advance), endDate: Date(timeIntervalSinceNow: advance + 3600), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!, optimiseBreaks: false)
            requestLog.addRequest(sampleRequest)
        }

        XCTAssertEqual(requestLog.requests.count, requestLog.maxEntries)
    }

    func testLogClearing() {

        let requestLog = RequestLog(testLog: true)
        // testing the size trimming function
        for _ in 0 ... 10 {
            let advance = Double(Int.random(in: -1000 ... 1000))
            let sampleRequest = RestRequest(beginDate: Date(timeIntervalSinceNow: advance), endDate: Date(timeIntervalSinceNow: advance + 3600), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!, optimiseBreaks: true)
            requestLog.addRequest(sampleRequest)
        }
        XCTAssertFalse(requestLog.requests.isEmpty)
        requestLog.clearLog()
        XCTAssertTrue(requestLog.requests.isEmpty)
    }

    // Tests for the DateAdjuster struct

    func testAdjustedBeginDate() {

        // test the function adjusts the day when the selected value lies in the past.
        let presentMoment1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 23, minute: 00))!
        let mockRawBeginDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 1, minute: 00))!
        let mockCorrectBeginDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 1, minute: 00))!

        XCTAssertEqual(DateAdjuster.adjustedBeginDate(mockRawBeginDate1, referenceNow: presentMoment1), mockCorrectBeginDate1)

        // test the function adjusts the day when the selected value lies in the future
        let presentMoment2 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 1, minute: 00))!
        let mockRawBeginDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 23, minute: 00))!
        let mockCorrectBeginDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 23, minute: 00))!

        XCTAssertEqual(DateAdjuster.adjustedBeginDate(mockRawBeginDate2, referenceNow: presentMoment2), mockCorrectBeginDate2)
    }

    func testAdjustedEndDate() {
        let presentMoment1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 23, minute: 00))!
        let mockBeginDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 1, minute: 00))!
        let mockRawEndDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 5, minute: 00))!
        let mockRawLandingDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 21, hour: 7, minute: 00))!
        let mockServiceTime1 = 5400
        let mockCorrectEndDate1 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 5, minute: 00))!

        // check the system correctly changes the day of the date for flight crew

        XCTAssertEqual(DateAdjuster.adjustedEndDate(mockBeginDate1, mockRawEndDate1, mockRawLandingDate1, mockServiceTime1, CrewFunction.flightCrew, referenceNow: presentMoment1), mockCorrectEndDate1)

        let mockCorrectEndDate2 = Calendar.current.date(from: DateComponents(year: 2022, month: 2, day: 22, hour: 5, minute: 30))!

        // check the system correctly changes the day of the date for cabin crew and also adjusts for service.

        XCTAssertEqual(DateAdjuster.adjustedEndDate(mockBeginDate1, mockRawEndDate1, mockRawLandingDate1, mockServiceTime1, CrewFunction.cabinCrew, referenceNow: presentMoment1), mockCorrectEndDate2)
    }

}
