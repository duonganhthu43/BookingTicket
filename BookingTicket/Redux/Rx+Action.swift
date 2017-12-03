//
//  Rx+Action.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import RxSwift

protocol Optionable {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: Optionable {
    var value: Wrapped? {
        return self
    }
}

extension ObservableType where E: Optionable, E.Wrapped == AnyAction {
    func dispatch() -> Observable<(AnyAction, ActionEvent)> {
        return filter { $0.value != nil }
            .map { $0.value! }
            .dispatch()
    }
}

private struct NotAnError: Error { }

extension ObservableType where E == ActionEvent {
    func errorsOnly() -> Observable<Error> {
        return map { event in
            switch event {
            case .error(let error):
                return error
            case .start, .completed, .cancelled:
                return NotAnError()
            }
            }
            .filter { !($0 is NotAnError) }
    }
}

extension ObservableType where E == (AnyAction, ActionEvent) {
    func errorsOnly() -> Observable<Error> {
        return map { $1 }.errorsOnly()
    }
}

extension ObservableType where E == ActionEvent {
    func completedOrError() -> Observable<Void> {
        return filter { event in
            if case let .error(error) = event {
                throw error
            }
            
            if case .completed = event {
                return true
            }
            
            return false
            }
            .map { _ in }
    }
}

extension ObservableType {
    func action(_ transform: @escaping (E) throws -> AnyAction?) -> Observable<AnyAction?> {
        return map(transform)
    }
    
    func actions(_ transform: @escaping (E) throws -> [AnyAction]?) -> Observable<AnyAction?> {
        return flatMap { value -> Observable<AnyAction?> in
            if let actions = try transform(value) {
                return Observable.from(actions)
            }
            return Observable.empty()
        }
    }
}
