//
//  StoreUpdater.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
protocol StoreUpdater {
    func reduce<S>(store: Store<S>, reducer: @escaping (S) -> S?)
}
