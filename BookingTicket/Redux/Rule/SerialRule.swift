//
//  SerialRule.swift
//  BookingTicket
//
//  Created by anhthu on 11/30/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
private struct SerialRule: Rule {
    init(_ types: [AnyAction.Type]) {
        self.types = types
        ordered = false
        condition = nil
    }
    
    init(_ type1: AnyAction.Type, _ type2: AnyAction.Type) {
        types = [type1, type2]
        ordered = true
        condition = nil
    }
    
    init<A1: AnyAction, A2: AnyAction>(_ type1: A1.Type, _ type2: A2.Type, condition: ((A1, A2) -> Bool)? = nil) {
        types = [type1, type2]
        ordered = true
        if let condition = condition {
            self.condition = { a1, a2 in
                guard let a1 = a1 as? A1, let a2 = a2 as? A2 else { return false }
                return condition(a1, a2)
            }
        } else {
            self.condition = nil
        }
    }
    
    func execute(wrapper: ActionWrapper, currentWrappers: [ActionWrapper]) {
        let wrapperType = type(of: wrapper.action)
        if ordered {
            guard types.count == 2, wrapperType == types[0] else { return }
            for w in currentWrappers where type(of: w.action) == types[1] {
                if condition?(wrapper.action, w.action) != false {
                    wrapper.after(wrapper: w)
                }
            }
        } else {
            guard !types.isEmpty, types.contains(where: { $0 == wrapperType }) else { return }
            for w in currentWrappers where types.contains(where: { $0 == type(of: w.action) }) {
                wrapper.after(wrapper: w)
            }
        }
    }
    
    // MARK: Properties
    
    private let types: [AnyAction.Type]
    private let ordered: Bool
    private let condition: ((AnyAction, AnyAction) -> Bool)?
}

extension AnyAction {
    static func after<A: AnyAction>(_ other: A.Type, condition: ((Self, A) -> Bool)? = nil) -> Rule {
        return SerialRule(self, other, condition: condition)
    }
    
    static func serial(condition: ((Self, Self) -> Bool)? = nil) -> Rule {
        return after(self, condition: condition)
    }
    
    static func serial<T: Equatable>(property: ((Self) -> T?)? = nil) -> Rule {
        var condition: ((Self, Self) -> Bool)? = nil
        if let property = property {
            condition = { property($0) == property($1) }
        }
        return after(self, condition: condition)
    }
}

extension Array where Element == AnyAction.Type {
    func after(_ other: AnyAction.Type) -> Rule {
        let rules = map {
            SerialRule($0, other)
        }
        return rules.count == 1 ? rules[0] : CombinedRule(rules: rules)
    }
    
    func serial() -> Rule {
        return SerialRule(self)
    }
}
