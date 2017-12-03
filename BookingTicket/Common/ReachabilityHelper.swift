//
//  ReachabilityHelper.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Reachability
import RxSwift
import CocoaLumberjackSwift

final class ReachabilityHelper {
    init() {
        do {
            reachability = Reachability()
            try reachability?.startNotifier()
            
            NotificationCenter.default.rx.notification(ReachabilityChangedNotification).subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf._reachable.onNext(strongSelf.isReachable)
            }).disposed(by: disposeBag)
            _reachable.onNext(isReachable)
        }
        catch {
            DDLogError("Unable to create Reachability")
        }
    }
    
    static let shared = ReachabilityHelper()
    private let disposeBag = DisposeBag()
    var isReachable: Bool {
        return reachability?.isReachable ?? false
    }
    private(set) var reachability: Reachability?
    
    private let _reachable = ReplaySubject<Bool>.create(bufferSize: 1)
    var reachable: Observable<Bool> {
        return _reachable
    }
}
