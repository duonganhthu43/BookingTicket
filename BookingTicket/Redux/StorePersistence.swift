//
//  StorePersistence.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import RxSwift

protocol StorePersistence {
    associatedtype State
    
    func saveState(_ state: State) -> Observable<Void>
    func loadState() -> Observable<State?>
}
