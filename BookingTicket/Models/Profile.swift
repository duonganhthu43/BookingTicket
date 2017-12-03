//
//  Profile.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
struct Profile {
    let id: String
    let email: String
    var firstName: String?
    var lastName: String?
    var location: String?
    var dateOfBirth: Date?
}

extension Profile: IdentifiableModelType {
    var identity: String {
        return id
    }
    
    var chatId: String {
        return email
    }
}

func ==(lhs: Profile, rhs: Profile) -> Bool {
    return  lhs.id              == rhs.id &&
        lhs.firstName       == rhs.firstName &&
        lhs.lastName        == rhs.lastName &&
        lhs.location        == rhs.location
}
