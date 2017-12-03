//
//  DispatcherPersistent.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import Foundation
protocol DispatcherPersistence {
    func loadActions() -> [Data]?
    func saveAction(data: Data, forKey key: String)
    func deleteAction(forKey key: String)
    func deleteAllActions()
}
