//
//  AppDelegate+Service.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import UIKit
protocol AppDelegateService: UIApplicationDelegate { }

extension AppDelegateService {
    var loggedIn: Bool {
        return false
    }
}
