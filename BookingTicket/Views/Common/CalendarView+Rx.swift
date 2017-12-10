//
//  CalendarView+Rx.swift
//  BookingTicket
//
//  Created by anhthu on 12/4/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import RxSwift
import RxCocoa
import FSCalendar
import UIKit

//MARK: Delegate

final class RxCalendarViewDelegateProxy: DelegateProxy<CalendarView,FSCalendarDelegate>, DelegateProxyType, FSCalendarDelegate, FSCalendarDelegateAppearance {
    static func registerKnownImplementations() {
         self.register { RxCalendarViewDelegateProxy(parentObject: $0) }
    }
    
    static func currentDelegate(for object: CalendarView) -> FSCalendarDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: FSCalendarDelegate?, to object: CalendarView) {
        object.delegate = castOptionalOrFatalError(delegate)
    }
    
    required init(parentObject: CalendarView) {
        calendar = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxCalendarViewDelegateProxy.self)
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let calendar: CalendarView = castOrFatalError(object)
        calendar.delegate = castOptionalOrFatalError(delegate)
    }
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let calendar: CalendarView = castOrFatalError(object)
        return calendar.delegate
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        _forwardToDelegate?.calendar(calendar, willDisplay: cell, for: date, at: position)
        guard let calendar = calendar as? CalendarView, let cell = cell as? CalendarCell else { return }
        calendar.configure(cell: cell, for: date, at: position)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date) -> Bool {
        return !date.isDatePast
    }
    
    weak private(set) var calendar: CalendarView?
}

//MARK: - DataSource

final class RxCalendarViewDataSourceProxy: DelegateProxy<CalendarView,FSCalendarDataSource>, DelegateProxyType, FSCalendarDataSource {
    static func registerKnownImplementations() {
        self.register { RxCalendarViewDataSourceProxy(parentObject: $0) }
    }
    
    static func currentDelegate(for object: CalendarView) -> FSCalendarDataSource? {
        return object.dataSource
    }
    
    static func setCurrentDelegate(_ delegate: FSCalendarDataSource?, to object: CalendarView) {
        object.dataSource = castOptionalOrFatalError(delegate)
    }
    
    required init(parentObject: CalendarView) {
        calendar = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxCalendarViewDataSourceProxy.self)
    }
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let calendar: CalendarView = castOrFatalError(object)
        return calendar.dataSource
    }
    
    weak private(set) var calendar: CalendarView?
}

//MARK: - Reactive

extension Reactive where Base: CalendarView {
    var delegate: RxCalendarViewDelegateProxy {
        return RxCalendarViewDelegateProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: FSCalendarDelegate) -> Disposable {
        return RxCalendarViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
    var dataSource: RxCalendarViewDataSourceProxy {
        return RxCalendarViewDataSourceProxy.proxy(for: base)
    }
    
    func setDataSource(_ dataSource: FSCalendarDataSource) -> Disposable {
        return RxCalendarViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: base)
    }
    
    var selections: UIBindingObserver<Base, [CalendarSelection]> {
        return UIBindingObserver(UIElement: base) { calendar, selections in
            calendar.selections = selections
        }
    }
    
    var dateSelected: ControlEvent<Date> {
        let select = delegate.methodInvoked(#selector(FSCalendarDelegate.calendar(_:didSelect:)))
            .map { a in
                return try castOrThrow(Date.self, a[1])
        }
        let deselect = delegate.methodInvoked(#selector(FSCalendarDelegate.calendar(_:didDeselect:)))
            .map { a in
                return try castOrThrow(Date.self, a[1])
        }
        return ControlEvent(events: Observable.of(select, deselect).merge())
    }
}
