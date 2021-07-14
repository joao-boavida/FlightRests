//
//  RequestLog.swift
//  FlightRests
//
//  Created by Joao Boavida on 12/03/2021.
//

import Foundation

final class RequestLog: ObservableObject {
    @Published private(set) var requests: Set<RestRequest>

    static let saveKey = "RequestLog"

    init() {
        let result = FileManager.loadFromDocumentsFolder(Set<RestRequest>.self, fileName: Self.saveKey)

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
        requests.insert(request)
        save()
    }

    /// Removes an element from the requests array, then saves
    /// - Parameter element: element to remove
    func removeRequest(_ element: RestRequest) {
        requests.remove(element)
        save()
    }
}
