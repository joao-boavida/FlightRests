//
//  NotificationManager.swift
//  FlightRests
//
//  Created by João Boavida on 09/06/2022.
//

import Foundation

struct NotificationManager {

    static let refreshNotificationKey = "RestPlaneUpdateNotification"

    static let nc = NotificationCenter.default

    static func postRefreshNotification() {
        nc.post(name: Notification.Name(refreshNotificationKey), object: nil)
    }

    static func observeRefreshNotification(action: @escaping () -> Void) -> NSObjectProtocol {
        let token = nc.addObserver(forName: Notification.Name(refreshNotificationKey), object: nil, queue: .main) { _ in
            action()
        }
        return token
    }

    static func removeRefreshObserver(token: NSObjectProtocol) {
        nc.removeObserver(token, name: Notification.Name(refreshNotificationKey), object: nil)
    }
}
