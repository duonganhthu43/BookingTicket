//
//  UserAccount.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import KeychainAccess
import CocoaLumberjackSwift
import RxSwift

final class UserAccount: KeychainPersistable {
    init(id: String, name: String, email: String, token: String) {
        self.id = id
        self.name = name
        self.email = email
        self.token = token
    }
    
    init?(data: [String: Any]) {
        guard
            let id = data["id"] as? String,
            let name = data["name"] as? String,
            let email = data["email"] as? String,
            let token = data["token"] as? String else { return nil }
        self.id = id
        self.name = name
        self.email = email
        self.token = token
    }
    
    func update(name: String) throws {
        self.name = name
        try save()
    }
    
    var data: [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["name"] = name
        dict["email"] = email
        dict["token"] = token
        return dict
    }
    
    let id: String
    let email: String
    let token: String
    private(set) var name: String
}
