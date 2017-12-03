//
//  CancelationRule.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

private struct CancellationRule: Rule {
    enum Strategy {
        case cancelFirst
        case cancelLatest
    }
    
    init<A1: AnyAction, A2: AnyAction>(when typeWhen: A1.Type, for typeFor: A2.Type, strategy: Strategy, condition: ((A1, A2) -> Bool)? = nil) {
        self.typeWhen = typeWhen
        self.typeFor = typeFor
        self.strategy = strategy
        if let condition = condition {
            self.condition = { a1, a2 in
                guard let a1 = a1 as? A1, let a2 = a2 as? A2 else { return false }
                return condition(a1, a2)
            }
        } else {
            self.condition = nil
        }
    }
    
    init(when typeWhen: AnyAction.Type, for typeFor: AnyAction.Type, strategy: Strategy) {
        self.typeWhen = typeWhen
        self.typeFor = typeFor
        self.strategy = strategy
        self.condition = nil
    }
    
    func execute(wrapper: ActionWrapper, currentWrappers: [ActionWrapper]) {
        guard type(of: wrapper.action) == typeWhen else { return }
        for w in currentWrappers where type(of: w.action) == typeFor {
            if condition?(wrapper.action, w.action) != false {
                switch strategy {
                case .cancelFirst:
                    w.cancel()
                case .cancelLatest:
                    wrapper.cancel()
                }
            }
        }
    }
    
    // MARK: Properties
    
    private let typeFor: AnyAction.Type
    private let typeWhen: AnyAction.Type
    private let strategy: Strategy
    private let condition: ((AnyAction, AnyAction) -> Bool)?
}

extension AnyAction {
    static func cancel<A: AnyAction>(_ other: A.Type, condition: ((Self, A) -> Bool)? = nil) -> Rule {
        return CancellationRule(when: self, for: other, strategy: .cancelFirst, condition: condition)
    }
    
    static func cancelledIf<A: AnyAction>(_ other: A.Type, condition: ((Self, A) -> Bool)? = nil) -> Rule {
        return CancellationRule(when: self, for: other, strategy: .cancelLatest, condition: condition)
    }
    
    static func cancel(_ others: AnyAction.Type...) -> Rule {
        return cancel(others, strategy: .cancelFirst)
    }
    
    static func cancelledIf(_ others: AnyAction.Type...) -> Rule {
        return cancel(others, strategy: .cancelLatest)
    }
    
    private static func cancel(_ others: [AnyAction.Type], strategy: CancellationRule.Strategy) -> Rule {
        let rules = others.map {
            CancellationRule(when: self, for: $0, strategy: strategy)
        }
        return rules.count == 1 ? rules[0] : CombinedRule(rules: rules)
    }
    
    static func singleFirst(condition: ((Self, Self) -> Bool)? = nil) -> Rule {
        return cancelledIf(self, condition: condition)
    }
    
    static func singleFirst<T: Equatable>(property: ((Self) -> T?)? = nil) -> Rule {
        var condition: ((Self, Self) -> Bool)? = nil
        if let property = property {
            condition = { property($0) == property($1) }
        }
        return cancelledIf(self, condition: condition)
    }
    
    static func singleLatest(condition: ((Self, Self) -> Bool)? = nil) -> Rule {
        return cancel(self, condition: condition)
    }
    
    static func singleLatest<T: Equatable>(property: ((Self) -> T?)? = nil) -> Rule {
        var condition: ((Self, Self) -> Bool)? = nil
        if let property = property {
            condition = { property($0) == property($1) }
        }
        return cancel(self, condition: condition)
    }
}

extension Array where Element == AnyAction.Type {
    func singleFirst() -> Rule {
        return single(strategy: .cancelLatest)
    }
    
    func singleLatest() -> Rule {
        return single(strategy: .cancelFirst)
    }
    
    private func single(strategy: CancellationRule.Strategy) -> Rule {
        let rules = flatMap { type in
            map {
                CancellationRule(when: type, for: $0, strategy: strategy)
            }
        }
        return rules.count == 1 ? rules[0] : CombinedRule(rules: rules)
    }
    
    func cancel(_ other: AnyAction.Type) -> Rule {
        let rules = map {
            CancellationRule(when: $0, for: other, strategy: .cancelFirst)
        }
        return rules.count == 1 ? rules[0] : CombinedRule(rules: rules)
    }
    
    func cancelledIf(_ other: AnyAction.Type) -> Rule {
        let rules = map {
            CancellationRule(when: $0, for: other, strategy: .cancelLatest)
        }
        return rules.count == 1 ? rules[0] : CombinedRule(rules: rules)
    }
}
