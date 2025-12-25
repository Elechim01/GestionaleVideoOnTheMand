//
//  AuthKeyChain.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 13/12/25.
//

import Foundation

final class AuthKeyChain {
    static var shared = AuthKeyChain()
    private let emalKey = "EMAIL"
    private let passwordKey = "PASSWORD"
    
    
    func setCredential(email: String, password: String)  {
        KeychainService.shared.save(email, for: emalKey)
        KeychainService.shared.save(password, for: passwordKey)
    }
    
    func redCredential()->(email: String?, password: String?) {
        let email = KeychainService.shared.read(emalKey)
        let password = KeychainService.shared.read(passwordKey)
        return (email, password)
    }
    
    func delete() {
        KeychainService.shared.delete(emalKey)
        KeychainService.shared.delete(passwordKey)
    }
}
