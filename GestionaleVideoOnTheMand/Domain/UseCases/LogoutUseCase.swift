//
//  LogoutUseCase.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 25/03/26.
//

import Foundation
import FirebaseCrashlytics

final class LogoutUseCase {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() throws {
        try repository.logOut()
        Crashlytics.crashlytics().setUserID("")
    }
}
