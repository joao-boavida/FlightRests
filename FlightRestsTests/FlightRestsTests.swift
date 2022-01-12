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
    func testDistributeRestUnits() throws {
        let minimumBreakUnits = 1
        let totalUnits = 30

        var numberOfUsers = 2

        for numberOfPeriods in 2 ... 4 {
            let result = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: numberOfPeriods, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits)

            checkDistributedRestUnits(result, numberOfPeriods, totalUnits, numberOfUsers)
        }

        numberOfUsers = 3

        let result = RestCalculator.distributeRestPlanUnits(numberOfUsers: numberOfUsers, numberOfPeriods: 3, minimumBreakUnits: minimumBreakUnits, totalUnits: totalUnits)

        checkDistributedRestUnits(result, 3, totalUnits, numberOfUsers)

    }

    func testRequestLogCleanUP() {

        let requestLog = RequestLog(testLog: true)

        // testing the removal of old entries

        let oldDate = DateComponents(calendar: .autoupdatingCurrent, timeZone: .autoupdatingCurrent, year: 2000, month: 11, day: 19).date!
        let oldRequest = RestRequest(creationDate: oldDate, beginDate: oldDate, endDate: oldDate, numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 10, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!)

        requestLog.addRequest(oldRequest)

        XCTAssertTrue(requestLog.requests.isEmpty)

        // testing the size trimming function
        for _ in 0 ... requestLog.maxEntries + 10 {
            let advance = Double(Int.random(in: -1000 ... 1000))
            let sampleRequest = RestRequest(beginDate: Date(timeIntervalSinceNow: advance), endDate: Date(timeIntervalSinceNow: advance + 3600), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!)
            requestLog.addRequest(sampleRequest)
        }

        XCTAssertEqual(requestLog.requests.count, requestLog.maxEntries)
    }

    func testLogClearing() {

        let requestLog = RequestLog(testLog: true)
        // testing the size trimming function
        for _ in 0 ... 10 {
            let advance = Double(Int.random(in: -1000 ... 1000))
            let sampleRequest = RestRequest(beginDate: Date(timeIntervalSinceNow: advance), endDate: Date(timeIntervalSinceNow: advance + 3600), numberOfUsers: 2, numberOfPeriods: 2, minimumBreakUnits: 2, crewFunction: .flightCrew, timeZone: TimeZone(abbreviation: "GMT")!)
            requestLog.addRequest(sampleRequest)
        }
        XCTAssertFalse(requestLog.requests.isEmpty)
        requestLog.clearLog()
        XCTAssertTrue(requestLog.requests.isEmpty)
    }

}
