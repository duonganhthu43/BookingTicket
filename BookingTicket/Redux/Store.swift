//
//  Store.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AnyStore: class { }

class Store<S>: AnyStore {
    typealias State = S
    
    init<P: StorePersistence>(initialState: S, persistence: P, dispatcher: Dispatcher = Dispatcher.shared) where P.State == S {
        stateVar = Variable(initialState)
        self.dispatcher = dispatcher
        
        persistence
            .loadState()
            .subscribe(onNext: { [weak self] in
                guard let state = $0 ?? self?.createFallbackState() else { return }
                self?.stateVar.value = state
                }, onError: { [weak self] in
                    self?.onError($0)
                }, onCompleted: { [weak self] in
                    self?.setupSavingState(persistence)
                    self?.readySubject.onNext(true)
            })
            .disposed(by: disposeBag)
    }
    
    init(initialState: S, dispatcher: Dispatcher = Dispatcher.shared) {
        stateVar = Variable(initialState)
        self.dispatcher = dispatcher
        readySubject.onNext(true)
    }
    
    func createFallbackState() -> S? {
        return nil
    }
    
    private func setupSavingState<P: StorePersistence>(_ persistence: P) where P.State == S {
        stateVar.asObservable()
            .skip(1)
            .flatMapLatest { [weak self] state -> Observable<Void> in
                // keep self alive why saving
                var strongSelf = self
                return persistence.saveState(state).do(onDispose: {
                    // this guard suppresses unused warning
                    guard strongSelf != nil else { return }
                    strongSelf = nil
                })
            }
            .subscribe(onError: { [weak self] in
                self?.onError($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func onError(_ error: Error) {
        dispatcher.storeErrorsSubject.onNext((self, error))
    }
    
    fileprivate func reduce(_ reducer: @escaping (S) -> S?) {
        _ = ready.subscribe(onNext: {
            self.queue.async {
                if let newState = reducer(self.stateVar.value) {
                    self.stateVar.value = newState
                }
            }
        })
    }
    
    // MARK: Rules
    
    func createRules() -> [Rule] {
        return []
    }
    
    fileprivate lazy var rules: [Rule] = self.createRules()
    
    // TODO Temp
    func getState() -> S {
        return stateVar.value
    }
    
    // MARK: Properties
    
    lazy var state: Driver<S> = {
        let stateVar = self.stateVar
        return self.ready
            .asDriver(onErrorJustReturn: ())
            .flatMap {
                stateVar.asDriver()
        }
    }()
    
    lazy var singleState: Single<S> = {
        let stateVar = self.stateVar
        return self.ready
            .flatMap {
                stateVar
                    .asObservable()
                    .take(1)
            }
            .asSingle()
    }()
    
    private let stateVar: Variable<S>
    fileprivate let dispatcher: Dispatcher
    private lazy var queue: DispatchQueue = DispatchQueue(label: "store", qos: .userInitiated)
    
    private let readySubject = BehaviorSubject<Bool>(value: false)
    lazy var ready: Observable<Void> = self.readySubject
        .filter { $0 }
        .take(1)
        .map { _ in }
    
    private let disposeBag: DisposeBag = DisposeBag()
}

// MARK: - Dispatcher

final class Dispatcher {
    init(persistence: DispatcherPersistence?) {
        self.persistence = persistence
        restoreActions()
    }
    
    func suspend() {
        stop(clear: false)
    }
    
    func cancel() {
        stop(clear: true)
        cancelSubject.onNext(())
    }
    
    private func stop(clear: Bool) {
        queue.sync {
            stopping = true
            actionDisposeBag = DisposeBag()
            executingWrappers.removeAllObjects()
            if clear {
                wrappers.removeAll()
                deleteAllActions()
            }
        }
    }
    
    func resume() {
        queue.async {
            self.stopping = false
            self.execute()
        }
    }
    
    fileprivate func dispatch<A: Action>(_ action: A) {
        dispatch(action, wrapper: BaseActionWrapper<A>(action))
    }
    
    fileprivate func dispatch<A: AsyncAction>(_ action: A) {
        dispatch(action, wrapper: AsyncActionWrapper<A>(action))
    }
    
    private func dispatch<A: Action>(_ action: A, wrapper: @escaping @autoclosure () -> ActionWrapper) {
        if let info = action.restoreInfo {
            action.restoreInfo = nil
            let w = wrapper()
            w.decode(from: info)
            wrappers.append(w)
            return
        }
        
        ready
            .subscribe(onNext: { [weak self] in
                self?.dispatchMain(action, createWrapper: wrapper)
            })
            .disposed(by: actionDisposeBag)
    }
    
    private func dispatchMain<A: Action>(_ action: A, createWrapper: @escaping () -> ActionWrapper) {
        guard !stopping else { return }
        
        let wrapper = createWrapper()
        wrapper.prepare(storeUpdater: storeUpdater)
        
        queue.async {
            let rules = action.store?.rules ?? []
            guard self.accept(wrapper: wrapper, rules: rules) else {
                self.eventsSubject.onNext((wrapper, .cancelled))
                return
            }
            self.wrappers.append(wrapper)
            self.saveAction(wrapper)
            self.execute()
        }
    }
    
    private func resume(infos: [[String: Any]]) {
        for info in infos {
            var info = info
            guard let action = info.removeValue(forKey: "action") as? AnyAction else { continue }
            action.restoreInfo = info
            _ = action.dispatch()
        }
        readySubject.onNext(true)
        execute()
    }
    
    private func execute() {
        guard !stopping else { return }
        for wrapper in wrappers where wrapper.beforeIds?.isEmpty != false && !executingWrappers.contains(wrapper) {
            execute(wrapper: wrapper)
        }
    }
    
    private func execute(wrapper: ActionWrapper) {
        guard !stopping else { return }
        eventsSubject.onNext((wrapper, .start))
        executingWrappers.add(wrapper)
        wrapper
            .execute(storeUpdater: storeUpdater)
            .subscribe(onError: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.queue.async {
                    strongSelf.eventsSubject.onNext((wrapper, .error(error)))
                    strongSelf.executeNext(wrapper: wrapper)
                }
                }, onCompleted: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.queue.async {
                        strongSelf.eventsSubject.onNext((wrapper, wrapper.cancelled ? .cancelled : .completed))
                        strongSelf.executeNext(wrapper: wrapper)
                    }
            })
            .disposed(by: actionDisposeBag)
    }
    
    private func executeNext(wrapper: ActionWrapper) {
        if let index = wrappers.index(where: { $0 === wrapper }) {
            wrappers.remove(at: index)
        }
        executingWrappers.remove(wrapper)
        deleteAction(wrapper)
        
        guard !stopping, wrapper.hasAfterIds else { return }
        
        let willExecuteWrappers = wrappers.filter {
            guard $0.beforeIds?.remove(wrapper.id) != nil else {
                return false
            }
            saveAction($0)
            return $0.beforeIds?.isEmpty != false && !executingWrappers.contains($0)
        }
        guard !willExecuteWrappers.isEmpty else { return }
        
        willExecuteWrappers.forEach(execute)
    }
    
    // MARK: Save & restore actions
    
    private func saveAction(_ wrapper: ActionWrapper) {
        guard wrapper.action is NSObject, wrapper.action is NSCoding else { return }
        guard let persistence = persistence, let info = wrapper.encodedInfo else { return }
        let data = NSKeyedArchiver.archivedData(withRootObject: info)
        persistence.saveAction(data: data, forKey: wrapper.id)
    }
    
    private func deleteAction(_ wrapper: ActionWrapper) {
        guard wrapper.action is NSObject, wrapper.action is NSCoding else { return }
        persistence?.deleteAction(forKey: wrapper.id)
    }
    
    private func deleteAllActions() {
        guard let persistence = persistence else { return }
        persistence.deleteAllActions()
    }
    
    private func restoreActions() {
        queue.async {
            let dataList = self.persistence?.loadActions() ?? []
            let infos = dataList.flatMap {
                NSKeyedUnarchiver.unarchiveObject(with: $0) as? [String: Any]
            }
            self.resume(infos: infos)
        }
    }
    
    // MARK: Process rules
    
    private func accept(wrapper: ActionWrapper, rules: [Rule]) -> Bool {
        guard !rules.isEmpty else { return true }
        for rule in rules {
            rule.execute(wrapper: wrapper, currentWrappers: wrappers)
            if wrapper.cancelled {
                break
            }
        }
        
        // save changed wrappers
        for w in wrappers where w.hasChanged {
            w.hasChanged = false
            saveAction(w)
        }
        return !wrapper.cancelled
    }
    
    // MARK: Properties
    
    static let shared = Dispatcher(persistence: nil)
    
    private let persistence: DispatcherPersistence?
    private var wrappers = [ActionWrapper]()
    private let executingWrappers = NSHashTable<ActionWrapper>.weakObjects()
    private lazy var queue: DispatchQueue = DispatchQueue(label: "dispatcher", qos: .userInitiated)
    private let eventsSubject = PublishSubject<(wrapper: ActionWrapper, event: ActionEvent)>()
    fileprivate let storeErrorsSubject = PublishSubject<(AnyStore, Error)>()
    private var actionDisposeBag = DisposeBag()
    private let storeUpdater = DefaultStoreUpdater()
    private var stopping = false
    private let readySubject = BehaviorSubject<Bool>(value: false)
    fileprivate let cancelSubject = PublishSubject<Void>()
    private lazy var ready: Observable<Void> = self.readySubject
        .filter { $0 }
        .take(1)
        .map { _ in }
    
    
    var actionEvents: Observable<(action: AnyAction, event: ActionEvent)> {
        return eventsSubject.asObservable().map { ($0.action, $1) }.observeOn(MainScheduler.instance)
    }
    
    var storeErrors: Observable<(AnyStore, Error)> {
        return storeErrorsSubject.asObservable().observeOn(MainScheduler.instance)
    }
}

// MARK: - StoreUpdater

private final class DefaultStoreUpdater: StoreUpdater {
    func reduce<S>(store: Store<S>, reducer: @escaping (S) -> S?) {
        theLock.lock()
        let counter = self.counter
        theLock.unlock()
        
        guard counter > 0 else {
            fatalError("Cannot update store outside reducer")
        }
        store.reduce(reducer)
    }
    
    func lock() {
        theLock.lock(); defer { theLock.unlock() }
        counter += 1
    }
    
    func unlock() {
        theLock.lock(); defer { theLock.unlock() }
        counter -= 1
    }
    
    func perform<T>(_ execute: (StoreUpdater) -> T) -> T {
        lock(); defer { unlock() }
        return execute(self)
    }
    
    // MARK: Properties
    
    private var counter = 0
    private let theLock = NSLock()
}

// MARK: - ActionWrapper

class ActionWrapper {
    init(_ action: AnyAction) {
        self.action = action
    }
    
    final func after(wrapper: ActionWrapper) {
        if !wrapper.hasChanged && !wrapper.hasAfterIds {
            wrapper.hasChanged = true
        }
        wrapper.hasAfterIds = true
        if beforeIds == nil {
            beforeIds = []
        }
        if beforeIds?.insert(wrapper.id) != nil {
            hasChanged = true
        }
    }
    
    final func cancel() {
        cancelSubject.onNext(())
        cancelled = true
    }
    
    fileprivate func prepare(storeUpdater: DefaultStoreUpdater) { }
    
    fileprivate func execute(storeUpdater: DefaultStoreUpdater) -> Observable<Void> {
        return Observable.empty()
    }
    
    // MARK: Encode & decode
    
    fileprivate final var encodedInfo: [String: Any]? {
        return [
            "action": action,
            "id": id,
            "hasAfterIds": hasAfterIds,
            "beforeIds": beforeIds ?? [],
            "cancelled": cancelled
        ]
    }
    
    fileprivate final func decode(from info: [String: Any]) {
        assert(action is NSObject)
        assert(action is NSCoding)
        if let id = info["id"] as? String {
            self.id = id
        }
        if let hasAfterIds = info["hasAfterIds"] as? Bool {
            self.hasAfterIds = hasAfterIds
        }
        if let beforeIds = info["beforeIds"] as? Set<String>, !beforeIds.isEmpty {
            self.beforeIds = beforeIds
        }
        if let cancelled = info["cancelled"] as? Bool {
            self.cancelled = cancelled
        }
        hasChanged = false
    }
    
    // MARK: Properties
    
    fileprivate static let actionScheduler: SchedulerType = {
        let queue = DispatchQueue(label: "action", qos: .default, attributes: .concurrent)
        return ConcurrentDispatchQueueScheduler(queue: queue)
    }()
    
    let action: AnyAction
    
    fileprivate var id = UUID().uuidString
    fileprivate var hasAfterIds = false
    fileprivate var beforeIds: Set<String>?
    fileprivate(set) var cancelled = false
    fileprivate let cancelSubject = PublishSubject<Void>()
    var hasChanged = false
}

private class BaseActionWrapper<A: Action>: ActionWrapper {
    override func prepare(storeUpdater: DefaultStoreUpdater) {
        guard !cancelled, let action = action as? A, let store = action.store else { return }
        store.reduce { state in
            storeUpdater.perform {
                action.reduce(state: state, updater: $0)
            }
        }
    }
}

private class AsyncActionWrapper<A: AsyncAction>: BaseActionWrapper<A> {
    fileprivate override func execute(storeUpdater: DefaultStoreUpdater) -> Observable<Void> {
        guard !cancelled, let action = action as? A, let store = action.store else {
            return Observable.empty()
        }
        return store.singleState
            .asObservable()
            .observeOn(type(of: self).actionScheduler)
            .flatMap(action.execute)
            .do(onNext: { result in
                store.reduce { state in
                    storeUpdater.perform {
                        action.reduce(state: state, result: result, updater: $0)
                    }
                }
            }, onError: { error in
                store.reduce { state in
                    storeUpdater.perform {
                        action.reduce(state: state, error: error, updater: $0)
                    }
                }
            })
            .map { _ in }
            .takeUntil(cancelSubject)
    }
}

// MARK: - Action extensions

extension Action {
    func dispatch() {
        store?.dispatcher.dispatch(self)
    }
}

extension AsyncAction {
    func dispatch() {
        store?.dispatcher.dispatch(self)
    }
}

extension Array where Element == AnyAction {
    func dispatch() {
        forEach { $0.dispatch() }
    }
}

private struct AssociatedKeys {
    static var restoreInfo = "restoreInfo"
}

extension AnyAction {
    fileprivate var restoreInfo: [String: Any]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.restoreInfo) as? [String: Any]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.restoreInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Rx extensions

private struct Reactive<A: Action>: ActionReactive {
    init(_ action: A) {
        self.action = action
    }
    
    func dispatch() -> Observable<ActionEvent> {
        return Observable
            .create { observer in
                let action = self.action
                guard let store = action.store else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                let disposable = CompositeDisposable()
                
                let eventDisposable = store.dispatcher.actionEvents
                    .subscribe(onNext: { info in
                        guard info.action === action else { return }
                        observer.onNext(info.event)
                        switch info.event {
                        case .completed, .error, .cancelled:
                            observer.onCompleted()
                        case .start:
                            return
                        }
                    })
                _ = disposable.insert(eventDisposable)
                
                let cancelDisposable = store.dispatcher.cancelSubject
                    .subscribe(onNext: {
                        observer.onCompleted()
                    })
                _ = disposable.insert(cancelDisposable)
                
                action.dispatch()
                return disposable
        }
    }
    
    private let action: A
}

extension Action {
    var rx: ActionReactive {
        return Reactive(self)
    }
}

extension ObservableType where E == AnyAction {
    func dispatch() -> Observable<(AnyAction, ActionEvent)> {
        return flatMap { action in
            action.rx
                .dispatch()
                .map { (action, $0) }
        }
    }
}
