//
//  CalendarView.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import FSCalendar
import Foundation

struct CalendarFont {
    static let day = UIFont.systemFont(ofSize: 20)
    static let dayOfWeek = UIFont.extraSmallSystemFont()
}

extension ColorPalette {
    static let dayText = UIColor(165, 173, 179)
    static let primaryHeaderLine = UIColor(152, 215, 223)
    static let primaryHeaderText = ColorPalette.mainColor
    static let backButtonBorder = UIColor(242, 242, 242)
    static let calendarPreviewTitle = UIColor(89, 104, 114)
    static let calendarPreviewContent = UIColor(89, 104, 114)
    static let calendarPreviewPeriod = UIColor( 165, 173, 179)
}

enum StyleGuide {}

extension StyleGuide {
    enum Calendar {
        static let boldTitleAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(),
                                                                        .foregroundColor: ColorPalette.calendarPreviewTitle]
        
        static let normalTitleAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(),
                                                                          .paragraphStyle: NSParagraphStyle.adjustedLineHeightParagraphStyle(2),
                                                                          .foregroundColor: ColorPalette.calendarPreviewTitle]
        
        static let contentAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(),
                                                                      .paragraphStyle: NSParagraphStyle.adjustedLineHeightParagraphStyle(2),
                                                                      .foregroundColor: ColorPalette.calendarPreviewContent]
        
        static let normalTextColor = UIColor(165, 173, 179)
        static let unselectableTextColor = UIColor(189, 195, 199)
        static let selectableTextColor = UIColor(89, 104, 114)
    }
}
final class CalendarView: FSCalendar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        firstWeekday = UInt(Calendar.current.firstWeekday)
        appearance.headerTitleFont = UIFont.smallBoldSystemFont()
        appearance.headerTitleColor = StyleGuide.Calendar.normalTextColor
        appearance.adjustsFontSizeToFitContentSize = false
        appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesSingleUpperCase]
        appearance.titleDefaultColor = StyleGuide.Calendar.selectableTextColor
        appearance.titleSelectionColor = StyleGuide.Calendar.selectableTextColor
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: FSCalendarDefaultCellReuseIdentifier)
        collectionView.register(CalendarHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var selections: [CalendarSelection] = [] {
        didSet {
            updateSelections()
        }
    }
}

//MARK: - Selection

struct CalendarSelection {
    var start: Date
    var end: Date
    var color: UIColor
    var filled: Bool
}

extension CalendarSelection: Hashable {
    var hashValue: Int {
        return "\(start)-\(end)".hashValue
    }
}
func == (lhs: CalendarSelection, rhs: CalendarSelection) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end && lhs.filled == rhs.filled && lhs.color == rhs.color
}

extension CalendarSelection {
    func contains(date: Date) -> Bool {
        return start <= date && date <= end
    }
    
    func isIntersect(with other: CalendarSelection) -> Bool {
        return start <= other.end && other.start <= end
    }
}

extension CalendarView {
    private func updateSelections() {
        for case let cell as CalendarCell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
                let date = calculator.date(for: indexPath) else { continue }
            let position = calculator.monthPosition(for: indexPath)
            configure(cell: cell, for: date, at: position)
        }
    }
    
    func configure(cell: CalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        guard monthPosition == .current, let selection = selections.first(where: { $0.contains(date: date) }) else {
            cell.setSelectionStyle(.none)
            return
        }
        
        let style: CalendarCellSelectionStyle
        let prevDate = date - 1.days
        let nextDate = date + 1.days
        switch (selection.contains(date: prevDate), selection.contains(date: nextDate)) {
        case (true, true):
            let isFirstDayOfWeek = date.isFirstDayOfWeek
            let isLastDayOfWeek = date.isLastDayOfWeek
            let isFirstDayOfMonth = date.isFirstDayOfMonth
            let isLastDayOfMonth = date.isLastDayOfMonth
            
            if isLastDayOfWeek && isFirstDayOfMonth || isFirstDayOfWeek && isLastDayOfMonth {
                style = .single(color: selection.color, filled: selection.filled)
            }
            else if isFirstDayOfWeek || isFirstDayOfMonth {
                style = .left(color: selection.color, filled: selection.filled)
            }
            else if isLastDayOfWeek || isLastDayOfMonth {
                style = .right(color: selection.color, filled: selection.filled)
            }
            else {
                style = .middle(color: selection.color, filled: selection.filled)
            }
            
        case (true, false):
            if date.isFirstDayOfWeek || date.isFirstDayOfMonth {
                style = .single(color: selection.color, filled: selection.filled)
            }
            else {
                style = .right(color: selection.color, filled: selection.filled)
            }
            
        case (false, true):
            if date.isLastDayOfWeek || date.isLastDayOfMonth {
                style = .single(color: selection.color, filled: selection.filled)
            }
            else {
                style = .left(color: selection.color, filled: selection.filled)
            }
            
        case (false, false):
            style = .single(color: selection.color, filled: selection.filled)
        }
        cell.setSelectionStyle(style)
    }
}



