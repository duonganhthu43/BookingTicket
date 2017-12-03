//
//  Rule.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

protocol Rule {
    func execute(wrapper: ActionWrapper, currentWrappers: [ActionWrapper])
}
