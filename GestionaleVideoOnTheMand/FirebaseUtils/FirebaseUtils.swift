//
//  FirebaseUtils.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 07/12/25.
//

import Foundation
import Firebase
import AuthenticationServices

class FirebaseUtils {
    static var shared = FirebaseUtils()
    
    func singIn(email: String, password: String) async throws ->  AuthDataResult {
        try await  withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error  {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Auth result nil"]))
                           
                }
                
            }
            
        }
    }
}
