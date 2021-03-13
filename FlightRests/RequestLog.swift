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

    private func save() {
        do {
            try FileManager.writeToDocumentsFolder(data: requests, fileName: Self.saveKey)
        } catch {
            print("error writing to docs directory")
        }
    }

    func addRequest(_ request: RestRequest) {
        requests.insert(request)
        save()
    }
}
