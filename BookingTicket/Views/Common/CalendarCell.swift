//
//  CalendarCell.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import FSCalendar

enum CalendarCellSelectionStyle {
    case none
    case single(color: UIColor, filled: Bool)
    case left(color: UIColor, filled: Bool)
    case middle(color: UIColor, filled: Bool)
    case right(color: UIColor, filled: Bool)
}

final class CalendarCell: FSCalendarCell {
    override init!(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.removeFromSuperlayer()
        subtitleLabel.removeFromSuperview()
        eventIndicator.removeFromSuperview()
        imageView.removeFromSuperview()
        contentView.insertSubview(selectionView, belowSubview: titleLabel)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }
    
    //MARK: Properties
    
    private let selectionView = CalendarSelectionIndicatorView()
}

extension CalendarCell {
    func setSelectionStyle(_ style: CalendarCellSelectionStyle) {
        selectionView.frame = contentView.bounds.insetBy(dx: 5, dy: 5).integral.innerSquare
        selectionView.style = style
        selectionView.isHidden = false
        updateTitleColor(filled: style.filled)
        titleLabel.font = date.isToday ? UIFont.boldSystemFont() : UIFont.systemFont()
        
        switch style {
        case .none:
            selectionView.isHidden = true
            
        case .left, .right:
            let d = ceil((bounds.width - selectionView.bounds.width) / 2 + 1)
            if case .left = style {
                selectionView.frame.growInPlace(right: d)
            }
            else {
                selectionView.frame.growInPlace(left: d)
            }
            
        case .middle:
            let d = ceil((bounds.width - selectionView.bounds.width) / 2 + 1)
            selectionView.frame.growInPlace(left: d, right: d)
            
        case .single:
            break
        }
    }
    
    private func updateTitleColor(filled: Bool) {
        titleLabel.textColor = filled ? UIColor.white : date.isDatePast ? StyleGuide.Calendar.unselectableTextColor : appearance.titleDefaultColor
    }
}

extension CalendarCellSelectionStyle {
    fileprivate var filled: Bool {
        switch self {
        case let .left(_, filled), let .right(_, filled), let .middle(_, filled), let .single(_, filled):
            return filled
        case .none:
            return false
        }
    }
}
