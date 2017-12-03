//
//  CombineRule.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

struct CombinedRule: Rule {
    func execute(wrapper: ActionWrapper, currentWrappers: [ActionWrapper]) {
        for rule in rules {
            rule.execute(wrapper: wrapper, currentWrappers: currentWrappers)
            if wrapper.cancelled {
                break
            }
        }
    }
    
    // MARK: Properties
    
    let rules: [Rule]
}
