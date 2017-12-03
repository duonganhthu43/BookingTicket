//
//  DateExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/4/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation

extension Date {
    private var firstDayOfWeek: Date? {
        let cal = Calendar.current
        let com = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return cal.date(from: com)
    }
    
    var isFirstDayOfWeek: Bool {
        return firstDayOfWeek == Calendar.current.startOfDay(for: self)
    }
    
    var isLastDayOfWeek: Bool {
        guard let first = firstDayOfWeek else { return false }
        var addCom = DateComponents()
        addCom.day = -1
        addCom.weekOfMonth = 1
        let cal = Calendar.current
        let last = cal.date(byAdding: addCom, to: first)
        return last == cal.startOfDay(for: self)
    }
    
    private var firstDayOfMonth: Date? {
        let cal = Calendar.current
        let com = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: com)
    }
    
    var isFirstDayOfMonth: Bool {
        return firstDayOfMonth == Calendar.current.startOfDay(for: self)
    }
    
    var isLastDayOfMonth: Bool {
        guard let first = firstDayOfMonth else { return false }
        var addCom = DateComponents()
        addCom.day = -1
        addCom.month = 1
        let cal = Calendar.current
        let last = cal.date(byAdding: addCom, to: first)
        return last == cal.startOfDay(for: self)
    }
    
    var noTime: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isDatePast: Bool {
        return self < Date().noTime
    }
    
    var isPast: Bool {
        return self < Date()
    }
    
    var inThisYear: Bool {
        return Calendar.current.compare(self, to: Date(), toGranularity: .year) == .orderedSame
    }
    
    var serverToLocalTime: Date {
        let tz = TimeZone.autoupdatingCurrent
        let seconds = -tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval(seconds), since: self)
    }
    
    var localToServerTime: Date {
        let tz = TimeZone.autoupdatingCurrent
        let seconds = tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval(seconds), since: self)
    }
    
    var roundedToNearest5Minutes: Date {
        let cal = Calendar.current
        let components = cal.dateComponents([.hour, .minute], from: self)
        let remainder = (components.minute ?? 0) % 5
        let interval = TimeInterval((5 - remainder) * 60)
        return addingTimeInterval(interval)
    }
}
