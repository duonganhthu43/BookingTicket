//
//  Scheduler.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import RxSwift

struct Schedulers {
    static var main: SchedulerType {
        return MainScheduler.instance
    }
    
    static let backgroundDefault: SchedulerType = {
        return ConcurrentDispatchQueueScheduler(qos: .default)
    }()
    
    static let backgroundUserInitiated: SchedulerType = {
        return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    }()
    
    static var JSONParsing: SchedulerType {
        return backgroundDefault
    }
}
