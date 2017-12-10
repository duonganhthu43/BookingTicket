//
//  DateStringExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation

import Foundation

private let dateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
private let shortDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d/yyyy"
    return formatter
}()
private let shortDateWithoutYearFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M/d"
    return formatter
}()
private let mediumDateWithoutYearFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d"
    return formatter
}()
private let mediumDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy"
    return formatter
}()

private let mediumMonthYearFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}()

private let mediumMonthOnlyFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter
}()
private let timeFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()
let dayOfWeekFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()
private let shortDayOfWeekFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    return formatter
}()

private let returningDateFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE M/d/yyyy"
    return formatter
}()

private let returningDateWithoutYearFormatter : DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE M/d"
    return formatter
}()
private let ordinalNumberFormatter : NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter
}()

extension Date {
    var dateString: String {
        let cal = Calendar.current
        if cal.isDateInYesterday(self) {
            return NSLocalizedString("Yesterday", comment: "")
        }
        else if cal.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "")
        }
        else if cal.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment: "")
        }
        else {
            let components = cal.dateComponents([.day], from: self.noTime, to: Date().noTime)
            if let day = components.day, day < 7 && day > -7 {
                return dayOfWeekFormatter.string(from: self)
            }
        }
        return dateFormatter.string(from: self)
    }
    var shortDateWithoutYearString: String {
        let cal = Calendar.current
        if cal.isDateInYesterday(self) {
            return NSLocalizedString("Yesterday", comment: "")
        }
        else if cal.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "")
        }
        else if cal.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment: "")
        }
        else {
            let components = cal.dateComponents([.day], from: self.noTime, to: Date().noTime)
            if let day = components.day, day < 7 && day > -7 {
                return shortDayOfWeekFormatter.string(from: self)
            }
        }
        return shortDateWithoutYearFormatter.string(from: self)
    }
    var mediumDateWithoutString: String {
        let cal = Calendar.current
        if cal.isDateInYesterday(self) {
            return NSLocalizedString("Yesterday", comment: "")
        }
        else if cal.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "")
        }
        else if cal.isDateInTomorrow(self) {
            return NSLocalizedString("Tomorrow", comment: "")
        }
        else {
            let components = cal.dateComponents([.day], from: self.noTime, to: Date().noTime)
            if let day = components.day, day < 7 && day > -7 {
                return shortDayOfWeekFormatter.string(from: self)
            }
        }
        return mediumDateWithoutYearFormatter.string(from: self)
    }
    
    var shortDateOfWeek: String {
        return shortDayOfWeekFormatter.string(from: self)
    }
    
    var timeString: String {
        return timeFormatter.string(from: self)
    }
    
    var dateTimeString: String {
        return Calendar.current.isDateInToday(self) ? timeString : "\(dateString) \(timeString)"
    }
    
    var timeOrDateString: String {
        return Calendar.current.isDateInToday(self) ? timeString : dateString
    }
    
    var eventDateTimeString: String {
        guard let day = Calendar.current.dateComponents([.day], from: self).day else {
            return dateTimeString
        }
        return "\(mediumMonthOnlyFormatter.string(from: self)) \(ordinalNumberFormatter.string(from: day as NSNumber) ?? String(day)) \(timeString)"
    }
    
    var postExpireString: String {
        return Calendar.current.isDateInToday(self) ? timeString : "\(dateString.lowercased()) \(timeString)"
    }
    
    var conversationLastSeenString: String {
        return Calendar.current.isDateInToday(self) ? timeString : "\(mediumDateWithoutString) at \(timeString)"
    }
    
    var conversationLastUpdateString: String {
        return Calendar.current.isDateInToday(self) ? timeString : shortDateWithoutYearString
    }
    
    var messageHeaderString: String {
        return Calendar.current.isDateInToday(self) ? timeString : "\(mediumDateWithoutString.uppercased()), \(timeString)"
    }
    
    var mediumDateString: String {
        return dateFormatter.string(from: self)
    }
    var mediumDateWithoutYearString: String {
        return mediumDateWithoutYearFormatter.string(from: self)
    }
    
    var returningDateString: String {
        return inThisYear ? returningDateWithoutYearFormatter.string(from: self) : returningDateFormatter.string(from: self)
    }
    
    var transactionDate: String {
        return mediumDateFormatter.string(from: self)
    }
    
    var transactionDateTime: String {
        return String(format: NSLocalizedString("%@ at %@", comment: "Jun 8 2017 at 2:30 PM"), transactionDate, timeString)
    }
    
    var timeAgo: String {
        return renderTimeAgo()
    }
    
    var notificationTimeAgo: String {
        return renderTimeAgo(NSLocalizedString("minute ago", comment: "minute ago"), minsUnit: NSLocalizedString("minutes ago", comment: "minutes ago"))
    }
    
    private func renderTimeAgo(_ minUnit: String = NSLocalizedString("min ago", comment: "min ago"), minsUnit: String = NSLocalizedString("mins ago", comment: "mins ago")) ->String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .month, .year], from: self, to: Date())
        if calendar.isDateInToday(self) {
            if let hour = components.hour, hour > 0 {
                let description = hour > 1 ? NSLocalizedString("hrs ago", comment: "") : NSLocalizedString("hr ago", comment: "")
                return "\(hour) \(description)"
            }
            if let minute = components.minute, minute >= 1 {
                let description = minute > 1 ? minsUnit : minUnit
                return "\(minute) \(description)"
            }
            return NSLocalizedString("Just now", comment: "")
        }
        if calendar.isDateInYesterday(self) {
            return String(format: NSLocalizedString("Yesterday at %@", comment: "2:00 PM"), timeFormatter.string(from: self))
        }
        if let day = components.day, day < 7 && components.month == 0 && components.year == 0  {
            return String(format: NSLocalizedString("%@ at %@", comment: "Sunday at 2:00 PM"), dayOfWeekFormatter.string(from: self), timeFormatter.string(from: self))
        }
        return String(format: NSLocalizedString("%@ at %@", comment: "May 4, 2016 at 2:00 PM"), dateFormatter.string(from: self), timeFormatter.string(from: self))
    }
}

// MARK: Calendar

extension Date {
    var leaveStatusDateString: String {
        if isToday {
            return NSLocalizedString("Today", comment: "")
        }
        else if inThisYear
        {
            return mediumDateWithoutYearFormatter.string(from: self)
        }
        return mediumDateFormatter.string(from: self)
    }
    
    var leaveStatusMediumDateString: String {
        return mediumDateFormatter.string(from: self)
    }
    
    var calendarSectionHeader: String {
        return (inThisYear ? mediumMonthOnlyFormatter : mediumMonthYearFormatter).string(from: self)
    }
}

