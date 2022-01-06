//
//  RequestLog.swift
//  FlightRests
//
//  Created by Joao Boavida on 12/03/2021.
//

import Foundation

final class RequestLog: ObservableObject {
    @Published private(set) var requests: [RestRequest]

    static let saveKey = "RequestLog"
    let maxEntries = 50
    var mockSaves = false

    init(testLog: Bool = false) {

        if testLog == true {
            self.requests = []
            self.mockSaves = true
            return
        } else {
            let result = FileManager.loadFromDocumentsFolder([RestRequest].self, fileName: Self.saveKey)

            switch result {
            case .success(let requests):
                self.requests = requests
            case .failure(let reason):
                if reason == .badData {
                    assertionFailure("Bad data obtained when trying to load recents file")
                }
                self.requests = []
            }
        }
    }

    /// Adds an element to the requests array, then saves
    /// - Parameter request: element to add
    func addRequest(_ request: RestRequest) {
        // check if any true duplicate (an element equal to a member of the array except for creation date) exists
        let isTrueDuplicate = requests.map {
            request.isTrueDuplicateOf($0)
        }.contains(true)

        guard isTrueDuplicate == false else { return } // in this case do not add the item

        // the item is not a true duplicate, then it should be added
        requests.append(request)
        save()
    }

    /// Removes an element from the requests array, then saves
    /// - Parameter element: element to remove
    func removeRequest(_ element: RestRequest) {
        if let index = requests.firstIndex(of: element) {
            requests.remove(at: index)
        }
        save()
    }

    /// Returns the crew function of the most recent entry in the log, and defaults to flight crew if the log is empty
    func mostRecentFunction() -> CrewFunction {
        requests.sorted().last?.crewFunction ?? .flightCrew
    }

    /// cleans up and saves the requests array to the documents folder
    private func save() {

        cleanUp()

        guard mockSaves == true else { return }

        do {
            try FileManager.writeToDocumentsFolder(data: requests, fileName: Self.saveKey)
        } catch {
            print("error writing to docs directory")
        }
    }

    /// Performs maintenance of the requests array by deleting requests older than 6 months and the oldest requests when there are more than 50 entries.
    /// - Parameter referenceDate: reference date for testing only, defaults to present date.
    private func cleanUp(referenceDate: Date = Date()) {

        // filter out requests created more than 6 months ago
        let sixMonthsAgo = Calendar.autoupdatingCurrent.date(byAdding: .month, value: -6, to: referenceDate)!
        var filtered = requests.sorted().filter {
            $0.creationDate >= sixMonthsAgo
        }

        // if there are more than the max allowable number of entries delete the oldest requests
        if filtered.count > maxEntries {
            let itemsToDelete = filtered.count - maxEntries
            filtered.removeFirst(itemsToDelete)
        }

        requests = filtered
    }
}
