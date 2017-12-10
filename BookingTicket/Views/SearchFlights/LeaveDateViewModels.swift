//
//  LeaveDateViewModels.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
struct Leave {
    let start: Date
    let end: Date?
}
final class LeaveDatesViewModel {
    enum Action {
        case selectDate(Date)
        case reset
        case removeEndDate
    }
    
    struct State {
        struct Values {
            var startDate: Date?
            var endDate: Date?
            var mainSelection: CalendarSelection?
            var previousSelections: [CalendarSelection]?
        }
        
        init(startDate: Date? = nil, endDate: Date? = nil, mainSelection: CalendarSelection? = nil) {
            values = Values(startDate: startDate, endDate: endDate, mainSelection: mainSelection, previousSelections: nil)
        }
        
        var values: Values
        var error: Error?
        var reset: Values?
        var hasScheduledLeaveForToday = false
    }
    
    init(startDate: Date?, endDate: Date?, roundTrip: Driver<Bool>) {
        originalStartDate = startDate
        self.endDate = endDate
        self.roundTrip = roundTrip
        let initialState = State(startDate: startDate, endDate: endDate, mainSelection: nil)
        let reducer = Reducer()
        self.state = Observable.combineLatest(actions, roundTrip.asObservable()).scan(initialState) {
            reducer.reduce($0, action: $1.0, isRoundTrip: $1.1)
        }.startWith(initialState).asDriver(onErrorJustReturn: initialState)
    }
    
    func dispatch(action: Action) {
        actions.onNext(action)
    }
    
    //MARK: Overlap
    
    enum OverlapKind {
        case none
        case current(startedToday: Bool)
        case future
    }
    
    func checkOverlapping(for date: Date) -> Observable<OverlapKind> {
        return checkOverlapping(for: date)
    }
    
    private func checkOverlapping(for date: Date) -> OverlapKind {
        return OverlapKind.none
    }
    
    //MARK: Date string
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM ''yy\nd\nEEEE"
        return formatter
    }()
    
    private static let dateFormatterWithoutYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM\nd\nEEEE"
        return formatter
    }()
    
    private static func dateString(for date: Date?, nilString: String) -> NSAttributedString {
        guard let date = date else {
            return NSAttributedString(string: nilString)
        }
        let str = (date.inThisYear ? dateFormatterWithoutYear : dateFormatter).string(from: date).uppercased() as NSString
        let final = NSMutableAttributedString(string: str as String)
        
        let i1 = str.range(of: "\n").location
        var attributes: [NSAttributedStringKey: Any] = [.foregroundColor: ColorPalette.mainColor,
                                                        .font: UIFont.systemFont()]
        final.setAttributes(attributes, range: NSRange(location: 0, length: i1))
        
        let i2 = str.range(of: "\n", options: .backwards).location
        attributes = [.foregroundColor: ColorPalette.mainColor,
                      .font: UIFont.lightSystemFont(ofSize: 30),
                      .paragraphStyle: NSParagraphStyle.adjustedLineHeightParagraphStyle(6, alignment: .center)]
        final.setAttributes(attributes, range: NSRange(location: i1, length: i2 - i1))
        
        attributes = [.foregroundColor: StyleGuide.Calendar.normalTextColor,
                      .font: UIFont.smallSystemFont()]
        final.setAttributes(attributes, range: NSRange(location: i2, length: str.length - i2))
        
        final.addAttributes([.kern: 1], range: NSRange(location: 0, length: str.length))
        return final.copy() as! NSAttributedString
    }
    
    //MARK: Properties
    
    private let actions = PublishSubject<Action>()
    private let disposeBag = DisposeBag()
    let originalStartDate: Date?
    let endDate: Date?
    let roundTrip: Driver<Bool>
    let state: Driver<State>

    var selections: Driver<[CalendarSelection]> {
        return state.map {
            var selections = $0.values.previousSelections ?? []
            if let mainSelection = $0.values.mainSelection {
                selections.insert(mainSelection, at: 0)
            }
            return selections
        }
    }
    
    var startDateString: Driver<NSAttributedString> {
        let startString = NSLocalizedString("Start Date", comment: "")
        return state.map { LeaveDatesViewModel.dateString(for: $0.values.startDate, nilString: startString) }
    }
    
    var endDateString: Driver<NSAttributedString> {
        let endString = NSLocalizedString("End Date", comment: "")
        return state.map { LeaveDatesViewModel.dateString(for: $0.values.endDate, nilString: endString) }
    }
    
    var canReset: Driver<Bool> {
        let s = state.map { $0.values != $0.reset }
        return Driver.combineLatest(s, fetching) { $0 && !$1 }
    }
    
    var canSave: Driver<Bool> {
        let s = state.map { $0.values.startDate != nil }
        let reachable = ReachabilityHelper.shared.reachable.asDriver(onErrorJustReturn: false)
        return Driver.combineLatest(s, reachable) { $0 && $1 }
    }
    
    var fetching: Driver<Bool> {
        return state.map { $0.values.previousSelections == nil }
    }
}

extension LeaveDatesViewModel.State.Values: Equatable {}
func ==(lhs: LeaveDatesViewModel.State.Values, rhs: LeaveDatesViewModel.State.Values) -> Bool {
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}

extension LeaveDatesViewModel {
    final class Reducer {
        func reduce(_ state: LeaveDatesViewModel.State, action: LeaveDatesViewModel.Action, isRoundTrip: Bool) -> LeaveDatesViewModel.State {
            switch action {
            case .selectDate(let date):
                return reduceSelectDate(date, state: state, isRoundTrip: isRoundTrip)
                
            case .reset:
                var state = state
                if let values = state.reset {
                    state.values = values
                }
                return state
                
            case .removeEndDate:
                var state = state
                guard let startDate = state.values.startDate else { return state}
                state.values.endDate = nil
                state.values.mainSelection = CalendarSelection(start: startDate, end: startDate, color: ColorPalette.mainColor, filled: true)
                return state
            }
        }
        
        private func reduceSelectDate(_ date: Date, state: LeaveDatesViewModel.State, isRoundTrip: Bool = true) -> LeaveDatesViewModel.State {
            guard !date.isDatePast else {
                return state
            }
            
            var state = state
            
            switch (state.values.startDate, state.values.endDate) {
            case (_?, _?), (nil, _?):
                state.values.startDate = date
                state.values.endDate = nil
                state.values.mainSelection = CalendarSelection(start: date, end: date, color: ColorPalette.mainColor, filled: true)
                
            case (let start?, nil):
                if start > date {
                    state.values.startDate = date
                    state.values.mainSelection = CalendarSelection(start: date, end: date, color: ColorPalette.mainColor, filled: true)
                }
                else {
                    if !isRoundTrip {
                        state.values.startDate = date
                        state.values.mainSelection = CalendarSelection(start: date, end: date, color: ColorPalette.mainColor, filled: true)
                    } else {
                    state.values.endDate = date
                        state.values.mainSelection = CalendarSelection(start: start, end: date, color: ColorPalette.mainColor, filled: true)
                    }
                }
                
            case (nil, nil):
                state.values.startDate = date
                state.values.mainSelection = CalendarSelection(start: date, end: date, color: ColorPalette.mainColor, filled: true)
            }
            
            reduceOverlap(state: &state)
            return state
        }
        
        private func reduceOverlap(state: inout LeaveDatesViewModel.State) {
            guard let mainSelection = state.values.mainSelection, var previousSelections = state.values.previousSelections else { return }
            let today = Date().noTime
            for (i, var selection) in previousSelections.enumerated().reversed() where selection.isIntersect(with: mainSelection) {
                //applied
                if selection.contains(date: today) && selection.start < mainSelection.start {
                    selection.end = mainSelection.start - 1.days
                    previousSelections[i] = selection
                }
                else {
                    previousSelections.remove(at: i)
                }
            }
            state.values.previousSelections = previousSelections
        }
    }
}
