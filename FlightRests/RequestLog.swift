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

    init() {
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

    /// saves the requests array to the documents folder
    private func save() {
        do {
            try FileManager.writeToDocumentsFolder(data: requests, fileName: Self.saveKey)
        } catch {
            print("error writing to docs directory")
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
}
