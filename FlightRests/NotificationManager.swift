//
//  NotificationManager.swift
//  FlightRests
//
//  Created by João Boavida on 09/06/2022.
//

import Foundation

/// A struct to deal with posting and observing NotificationCenter notifications
struct NotificationManager {

    /// The key to be used in the refresh notification
    static let refreshNotificationKey = "RestPlanRefreshNotification"

    /// The notification center to be used for the refresh notification
    static let nc = NotificationCenter.default

    /// Posts a refresh notification in the default center
    static func postRefreshNotification() {
        nc.post(name: Notification.Name(refreshNotificationKey), object: nil)
    }

    /// Adds an observer for a the refresh notification and performs an action
    /// - Parameter action: the action to be performed
    /// - Returns: a token for the observer so it can later be removed
    static func observeRefreshNotification(action: @escaping () -> Void) -> NSObjectProtocol {
        let token = nc.addObserver(forName: Notification.Name(refreshNotificationKey), object: nil, queue: .main) { _ in
            action()
        }
        return token
    }

    /// Removes a refresh notification observer with a given token
    /// - Parameter token: the token of the observer to be removed
    static func removeRefreshObserver(token: NSObjectProtocol) {
        nc.removeObserver(token, name: Notification.Name(refreshNotificationKey), object: nil)
    }
}
