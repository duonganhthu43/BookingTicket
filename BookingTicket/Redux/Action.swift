//
//  Action.swift
//  BookingTicket
//
//  Created by anhthu on 11/28/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import RxSwift
protocol ActionReactive {
    func dispatch() -> Observable<ActionEvent>
}

protocol AnyAction: class {
    func dispatch()
    
    var rx: ActionReactive { get }
}

protocol Action: AnyAction {
    associatedtype State
    
    var store: Store<State>? { get }
    
    func reduce(state: State, updater: StoreUpdater) -> State?
}

protocol AsyncAction: Action {
    associatedtype Result
    
    func reduce(state: State, result: Result, updater: StoreUpdater) -> State?
    func reduce(state: State, error: Error, updater: StoreUpdater) -> State?
    func execute(state: State) -> Observable<Result>
}

extension AsyncAction {
    func reduce(state: State, updater: StoreUpdater) -> State? {
        return nil
    }
    
    func reduce(state: State, error: Error, updater: StoreUpdater) -> State? {
        return nil
    }
}
