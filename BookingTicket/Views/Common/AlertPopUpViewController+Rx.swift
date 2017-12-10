//
//  AlertPopUpViewController+Rx.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import RxSwift
import RxCocoa
import UIKit

final class RxAlertPopupViewControllerDelegateProxy: DelegateProxy<AlertPopupViewController,AlertPopupViewControllerDelegate>, DelegateProxyType, AlertPopupViewControllerDelegate {
    static func registerKnownImplementations() {
        self.register { RxAlertPopupViewControllerDelegateProxy(parentObject: $0) }
    }
    
    static func currentDelegate(for object: AlertPopupViewController) -> AlertPopupViewControllerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AlertPopupViewControllerDelegate?, to object: AlertPopupViewController) {
        object.delegate = delegate
    }
    
    required init(parentObject: AlertPopupViewController) {
        super.init(parentObject: parentObject, delegateProxy: RxAlertPopupViewControllerDelegateProxy.self)
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let controller = object as! AlertPopupViewController
        controller.delegate = delegate as? AlertPopupViewControllerDelegate
    }
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let controller = object as! AlertPopupViewController
        return controller.delegate
    }
}

extension Reactive where Base: AlertPopupViewController {
    var delegate: DelegateProxy<AlertPopupViewController,AlertPopupViewControllerDelegate>  {
        return RxAlertPopupViewControllerDelegateProxy.proxy(for: base)
    }
    
    var didTapMainButton: Observable<Void> {
        return delegate
            .methodInvoked(#selector(AlertPopupViewControllerDelegate.alertPopupViewControllerDidTapMainButton(_:)))
            .map { _ in }
    }
    
    var didCancel: Observable<Void> {
        return delegate
            .methodInvoked(#selector(AlertPopupViewControllerDelegate.alertPopupViewControllerDidCancel(_:)))
            .map { _ in }
    }
}

extension Reactive where Base: AlertPopupViewController {
    static func create(parent: UIViewController?, animated: Bool = true, configure: ((AlertPopupViewController) throws -> Void)?) -> Observable<AlertPopupViewController> {
        return Observable.create { [weak parent] observer in
            let controller = Base()
            let dismissDisposable = controller.rx
                .didCancel
                .subscribe(onNext: {
                    observer.onCompleted()
                })
            
            do {
                try configure?(controller)
            }
            catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(controller, animated: animated, completion: nil)
            observer.on(.next(controller))
            
            return dismissDisposable
        }
    }
    
    static func present(parent: UIViewController?, animated: Bool = true, configure: ((AlertPopupViewController) throws -> Void)?) -> Observable<Bool> {
        return create(parent: parent, animated: animated, configure: configure)
            .flatMap { $0.rx.didTapMainButton }
            .map { true }
            .ifEmpty(default: false)
            .take(1)
    }
}
