//
//  DateMathExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/4/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation

func - (lhs: Date, rhs: DateComponents) -> Date {
    return lhs + (-rhs)
}

func + (lhs: Date, rhs: DateComponents) -> Date {
    let cal = Calendar.current
    return cal.date(byAdding: rhs, to: lhs)!
}

prefix func - (dateComponents: DateComponents) -> DateComponents {
    let components: [Calendar.Component] = [.second, .minute, .hour, .day, .month, .year, .yearForWeekOfYear, .weekOfYear, .weekday, .quarter, .weekdayOrdinal, .weekOfMonth]
    var newComponents = DateComponents()
    for component in components {
        if let value = dateComponents.value(for: component), value != NSDateComponentUndefined {
            newComponents.setValue(-value, for: component)
        }
    }
    return newComponents
}

extension Int {
    var seconds: DateComponents {
        return toDateComponents(type: .second)
    }
    
    var minutes: DateComponents {
        return toDateComponents(type: .minute)
    }
    
    var hours: DateComponents {
        return toDateComponents(type: .hour)
    }
    
    var days: DateComponents {
        return toDateComponents(type: .day)
    }
    
    var weeks: DateComponents {
        return toDateComponents(type: .weekOfYear)
    }
    
    var months: DateComponents {
        return toDateComponents(type: .month)
    }
    
    var years: DateComponents {
        return toDateComponents(type: .year)
    }
    
    private func toDateComponents(type: Calendar.Component) -> DateComponents {
        var dateComponents = DateComponents()
        dateComponents.setValue(self, for: type)
        return dateComponents
    }
}
