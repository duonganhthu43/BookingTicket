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

//MARK: Delegate

final class RxCalendarViewDelegateProxy: DelegateProxy, DelegateProxyType, FSCalendarDelegate, FSCalendarDelegateAppearance {
    required init(parentObject: AnyObject) {
        calendar = (parentObject as! CalendarView)
        super.init(parentObject: parentObject)
    }
    
    override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let calendar = object as! CalendarView
        return castOrFatalError(RxCalendarViewDelegateProxy(parentObject: calendar))
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

final class RxCalendarViewDataSourceProxy: DelegateProxy, DelegateProxyType, FSCalendarDataSource {
    required init(parentObject: AnyObject) {
        calendar = (parentObject as! CalendarView)
        super.init(parentObject: parentObject)
    }
    
    override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let calendar = object as! CalendarView
        return castOrFatalError(RxCalendarViewDataSourceProxy(parentObject: calendar))
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let calendar: CalendarView = castOrFatalError(object)
        calendar.dataSource = castOptionalOrFatalError(delegate)
    }
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let calendar: CalendarView = castOrFatalError(object)
        return calendar.dataSource
    }
    
    weak private(set) var calendar: CalendarView?
}

//MARK: - Reactive

extension Reactive where Base: CalendarView {
    var delegate: DelegateProxy {
        return RxCalendarViewDelegateProxy.proxyForObject(base)
    }
    
    func setDelegate(_ delegate: FSCalendarDelegate) -> Disposable {
        return RxCalendarViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
    var dataSource: DelegateProxy {
        return RxCalendarViewDataSourceProxy.proxyForObject(base)
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
