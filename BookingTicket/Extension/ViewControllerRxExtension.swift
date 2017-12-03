//
//  ViewControllerRxExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIViewController {
    private func trigger(_ selector: Selector) -> Observable<Void> {
        return sentMessage(selector).map { _ in }
    }
    
    var viewWillAppear: Observable<Void> {
        return trigger(#selector(UIViewController.viewWillAppear(_:)))
    }
    
    var viewDidAppear: Observable<Void> {
        return trigger(#selector(UIViewController.viewDidAppear(_:)))
    }
    
    var viewWillDisappear: Observable<Void> {
        return trigger(#selector(UIViewController.viewWillDisappear(_:)))
    }
    
    var viewDidDisappear: Observable<Void> {
        return trigger(#selector(UIViewController.viewDidDisappear(_:)))
    }
}
