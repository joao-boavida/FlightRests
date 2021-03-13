//
//  FileManagerExtension.swift
//  BucketListHWS14 + Custom code
//
//  Created by Joao Boavida on 14/12/2020.
//

import Foundation

// solution of challenge in the techniques page of the Bucketlist project. Why not try writing the decoder too?
extension FileManager {
    static func writeToDocumentsFolder<T: Codable>(data: T, fileName: String) throws {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        let encoder = JSONEncoder()

        var encodedData: Data

        do {
            try encodedData = encoder.encode(data)
        } catch {
            throw error
        }

        do {
            try encodedData.write(to: fileURL)
        } catch {
            throw error
        }
    }

    enum ReadError: Error {
        case fileNotFound, badData
    }

    // extension to load from docs folder
    static func loadFromDocumentsFolder<T: Codable>(_ type: T.Type, fileName: String) -> Result<T, ReadError> {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        let decoder = JSONDecoder()

        do {
            let data = try Data(contentsOf: fileURL)
            do {
                let decoded = try decoder.decode(type, from: data)
                return .success(decoded)
            } catch {
                return .failure(.badData)
            }
        } catch {
            return.failure(.fileNotFound)
        }
    }

}
