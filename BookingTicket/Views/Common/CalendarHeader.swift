//
//  CalendarHeader.swift
//  BookingTicket
//
//  Created by anhthu on 12/4/17.
//  Copyright © 2017 anhthu. All rights reserved.
//


import FSCalendar

final class CalendarHeader: FSCalendarStickyHeader {
    override init(frame: CGRect) {
        super.init(frame: frame)
        for subview in subviews[0].subviews {
            if !(subview is UILabel) {
                subview.isHidden = true
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
    
    private var _month: Date!
    override var month: Date! {
        get {
            return _month
        }
        set {
            _month = newValue
            let year = Calendar.current.component(.year, from: newValue)
            let curYear = Calendar.current.component(.year, from: Date())
            calendar.formatter.dateFormat = year > curYear ? "MMMM yyyy" : "MMMM"
            let text = calendar.formatter.string(from: month).uppercased()
            titleLabel.attributedText = NSAttributedString(string: text, attributes: [.kern: 1])
        }
    }
}

