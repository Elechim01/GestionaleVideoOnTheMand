//
//  CredentialRepository.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 03/04/26.
//

import Foundation

protocol CredentialRepositoryProtocol {
    func readCredential() throws -> (email: String, password: String)
    func saveCredential(email: String, password: String) throws
    func readRememberedCredential() throws -> (email: String, password: String)
    func saveRememberedCredential(email: String, password: String) throws
    func deleteCredential()
    func deleteRememberedCredential()
    func existRememberedCredentials() -> Bool
}
