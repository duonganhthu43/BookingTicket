//
//  KeyChainPersistable.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import KeychainAccess
import CocoaLumberjackSwift

protocol KeychainPersistable {
    init?(data: [String: Any])
    var data: [String: Any] { get }
}

extension KeychainPersistable {
    private static var keychain: Keychain {
        return Keychain(service: "BookingTicket")
    }
    
    private static var key: String {
        return String(reflecting: Self.self)
    }
    
    private var key: String {
        return Self.key
    }
    
    func save() throws {
        let nsdata = NSKeyedArchiver.archivedData(withRootObject: data)
        try Self.keychain.set(nsdata, key: key)
    }
    
    static func delete() {
        do {
            try keychain.remove(key)
        } catch {
            DDLogError(error.localizedDescription)
        }
    }
    
    static func get() -> Self? {
        do {
            guard let nsdata = try keychain.getData(key),
                let data = NSKeyedUnarchiver.unarchiveObject(with: nsdata) as? [String: Any]
                else { return nil }
            return Self(data: data)
        } catch {
            DDLogError(error.localizedDescription)
            return nil
        }
    }
}
