//
//  NotificationCenterExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation

private let key = "info"

extension NotificationCenter {
    func post(name: NSNotification.Name, data: Any) {
        let info = [key: data]
        post(name: name, object: nil, userInfo: info)
    }
}

extension Foundation.Notification {
    var data: Any? {
        return userInfo?[key]
    }
}

extension NSNotification {
    var data: Any? {
        return userInfo?[key]
    }
}
