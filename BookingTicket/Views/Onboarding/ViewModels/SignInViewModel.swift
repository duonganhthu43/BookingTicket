
//
//  SignInViewModel.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa
final class SignInViewModel {
    init() {
        email = Variable("")
        password = Variable("")
    }
    
    func loginWithOwnCredential() -> Observable<Bool> {
        return validateEmail()
    }
    
    func validateEmail() -> Observable<Bool> {
        return Observable.just(email.value.isEmpty || !email.value.isValidEmail)
    }
    
    let email: Variable<String>
    let password: Variable<String>
}
extension SignInViewModel {
    static func sendAuthenticationNotification(info: AuthenticatedInfo) {
        NotificationCenter.default.post(name: .didAuthenticate, data: info)
    }
}
// MAKR: Notification

extension NSNotification.Name {
    static let didAuthenticate = NSNotification.Name("didAuthenticate")
}
