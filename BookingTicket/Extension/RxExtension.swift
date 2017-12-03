//
//  RxExtension.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import RxSwift
import RxCocoa
import SVProgressHUD

extension ObservableType {
    func process(_ process: @escaping (Self.E) -> Self.E) -> Observable<Self.E> {
        return observeOn(Schedulers.backgroundDefault).map(process).observeOn(Schedulers.main)
    }
    
    func takeUntil<O1: ObservableType, O2: ObservableType>(_ stop: O1, restartWhen start: O2) -> Observable<E> {
        return Observable.concat([
            takeUntil(stop),
            Observable.never().takeUntil(start),
            Observable.deferred {
                self.takeUntil(stop, restartWhen: start)
            }
            ])
    }
}

extension ObservableType where E: Optionable {
    func ignoreNil() -> Observable<E.Wrapped> {
        return flatMap { e -> Observable<E.Wrapped> in
            guard let value = e.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
    
    func flatMapNonOptional(_ selector: @escaping (E.Wrapped) throws -> Observable<Void>) -> Observable<Void> {
        return flatMap { e -> Observable<Void> in
            guard let value = e.value else {
                return Observable.just(())
            }
            return try selector(value)
        }
    }
    
    func flatMapNonOptional<T>(_ selector: @escaping (E.Wrapped) throws -> Observable<[T]>) -> Observable<[T]> {
        return flatMap { e -> Observable<[T]> in
            guard let value = e.value else {
                return Observable.just([])
            }
            return try selector(value)
        }
    }
}

extension ObservableType {
    func requireNetwork() -> Observable<E> {
        return self.do(onNext: { _ in
            if !ReachabilityHelper.shared.isReachable {
                ToastManager.shared.presentNoInternetConnectionError()
            }
        })
            .flatMap { e in
                ReachabilityHelper.shared.isReachable ? Observable.just(e) : Observable.empty()
        }
    }
    
    func trackingHUD(dismissOnNext: Bool = true) -> Observable<E> {
        return observeOn(Schedulers.main).do(onNext: { _ in
            guard dismissOnNext else { return }
            SVProgressHUD.popActivity()
        }, onSubscribe: {
            SVProgressHUD.show(withStatus: nil, maskType: .clear)
        }, onDispose: {
            SVProgressHUD.popActivity()
        })
    }
    
    func ignoreError() -> Observable<E> {
        return self.catchError({ _ -> Observable<Self.E> in
            Observable.empty()
        })
    }
}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(_ valueOnFailure: E) -> Observable<E> {
        return self.asObservable()
            .catchError { (e) -> Observable<E> in
                ReachabilityHelper.shared.reachable
                    .filter { $0 }
                    .flatMap { _ in Observable.error(e) }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
    
    func reachable() -> Observable<E> {
        return ReachabilityHelper.shared.reachable.filter { $0 }.take(1).flatMap { _ in self }
    }
}

extension ObservableType where E == String {
    func trim() -> Observable<E> {
        return map { $0.trim() }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E == String {
    func trim() -> Driver<E> {
        return map { $0.trim() }
    }
}

extension ObservableType where E: Collection {
    func filter(from searchText: Observable<String>, emptyResultIfTextEmpty: Bool = false, filtering: @escaping (E.Iterator.Element, String) -> Bool) -> Observable<[Self.E.Iterator.Element]> {
        return Observable.combineLatest(self, searchText.startWith("")) { results, text in
            guard !text.isEmptyOrWhiteSpace else {
                return emptyResultIfTextEmpty ? [] : Array(results)
            }
            let phrase = text.trim()
            let words = phrase.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            return results.filter {
                for word in words where !filtering($0, word) {
                    return false
                }
                return true
            }
        }
    }
}

extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: Collection {
    func filter(from searchText: Driver<String>, emptyResultIfTextEmpty: Bool = false, filtering: @escaping (E.Iterator.Element, String) -> Bool) -> Driver<[Self.E.Iterator.Element]> {
        return Driver.combineLatest(self, searchText.startWith("")) { results, text in
            guard !text.isEmptyOrWhiteSpace else {
                return emptyResultIfTextEmpty ? [] : Array(results)
            }
            let phrase = text.trim()
            let words = phrase.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            return results.filter {
                for word in words where !filtering($0, word) {
                    return false
                }
                return true
            }
        }
    }
}

extension ObservableType {
    func wait(action: @escaping (E) -> AnyAction?, onError: @escaping (Error) -> Void = ToastManager.shared.presentAnimated, sendNextWhenNilAction: Bool = false) -> Observable<Void> {
        return requireNetwork()
            .flatMapFirst { value -> Observable<Void> in
                guard let a = action(value) else {
                    return sendNextWhenNilAction ? Observable.just(()) : Observable.empty()
                }
                return a.rx
                    .dispatch()
                    .trackingHUD(dismissOnNext: false)
                    .completedOrError()
                    .do(onError: onError)
                    .ignoreError()
        }
    }
}

//MARK: - Utilities

func castOrFatalError<T>(_ value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        fatalError("Failure converting from \(value) to \(T.self)")
    }
    return result
}

func castOptionalOrFatalError<T>(_ value: Any?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    
    return returnValue
}
