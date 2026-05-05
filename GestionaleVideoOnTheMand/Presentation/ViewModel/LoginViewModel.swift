//
//  LoginHomeViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Services
import GoogleSignIn
import CryptoKit
import ElechimCore

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var showAlert : Bool = false
    @Published var alertMessage : String = ""
    @Published var email: String = ""
    @Published var password : String = ""
    @Published var canShowAutoFill: Bool = false
    @Published var emailToRestore: String = ""
    
    private let loginUseCase: LoginUseCase
    private let restoreSessionUseCase: RestoreSessionUseCase
    private let logoutUseCase: LogoutUseCase
    private let sessionManager: SessionManager
    private let getRememberedCredentialUseCase: GetRememberedCredentialsUseCase
    private let deleteRememberedCredentialUseCase: DeleteRememberedCredentialsUseCase
    private let existRememberedCredentialUseCase: ExistRememberedCredentialUseCase
    private let restorePasswordUseCase: RestorePasswordUseCase
    
    var getCheck: Bool{
        if(email.isEmpty){
            alertMessage = "Il campo email è vuoto"
            return false
        }
        if(!Utils.isValidEmail(email)){
            alertMessage = "L'email non è valida"
            return false
        }
        if(password.isEmpty){
           alertMessage = "Il campo password è vuoto"
            return false
        }
        if(!Utils.isValidPassword(testStr: password)){
            alertMessage = "la password non è valida, deve comprendere: Almeno una maiuscola, Almeno un numero, Almeno una minuscola, 8 caratteri in totale"
            return false
        }
        return true
    }
    
    var checkEmailToRestore: Bool {
        if(!Utils.isValidEmail(emailToRestore)) {
            return false
        }
        return true
    }
    
    init(loginUseCase: LoginUseCase,
         restoreSessionUseCase: RestoreSessionUseCase,
         logoutUseCase: LogoutUseCase,
         getRememberedCredentialUseCase: GetRememberedCredentialsUseCase,
         deleteRememberedCredentialUseCase: DeleteRememberedCredentialsUseCase,
         existRememberedCredentialUseCase: ExistRememberedCredentialUseCase,
         restorePasswordUseCase: RestorePasswordUseCase,
         sessionManager: SessionManager) {
        self.loginUseCase = loginUseCase
        self.restoreSessionUseCase = restoreSessionUseCase
        self.getRememberedCredentialUseCase = getRememberedCredentialUseCase
        self.deleteRememberedCredentialUseCase = deleteRememberedCredentialUseCase
        self.existRememberedCredentialUseCase = existRememberedCredentialUseCase
        self.restorePasswordUseCase = restorePasswordUseCase
        self.logoutUseCase = logoutUseCase
        self.sessionManager = sessionManager
    }
    
    
    //    Funzioni di Login e Logout
    func login() async -> Bool {
        CustomLog.debug(category: .VM, "\(#function)")
        do {
            guard getCheck else  {
                self.showAlert.toggle()
                return false
            }
            
            guard Utils.isConnectedToInternet() else {
                throw CustomError.connectionError
            }
            let id = try await loginUseCase.execute(email: email, password: password)
            sessionManager.saveSession(id: id)
            return true
        } catch {
            self.showError(from: error)
            return false
        }
    }
    
    func restoreSession() async -> Bool {
        CustomLog.debug(category: .VM, "\(#function)")
        do {
            guard  Utils.isConnectedToInternet()  else {
                throw CustomError.connectionError
            }
            return  try await restoreSessionUseCase.execute()
            
        } catch {
            showError(from: error)
            return false
        }
    }
    
    func logOut() -> Bool{
        CustomLog.debug(category: .VM, "\(#function)")
        do {
            try logoutUseCase.execute()
            sessionManager.clearSession()
            CustomLog.debug(category: .VM, "Logout sessione corretto")
            return true
            
        } catch  {
            showError(from: error)
            return false
        }
    }
    
    func loadRememberCredential() {
        CustomLog.debug(category: .VM, "\(#function)")
        do {
            let credential = try getRememberedCredentialUseCase.execute()
            self.email = credential.email
            self.password = credential.password
        } catch  {
            showError(from: error)
        }
    }
    
    func deleteRememberCredential() {
        CustomLog.debug(category: .VM, "\(#function)")
        deleteRememberedCredentialUseCase.execute()
        checkStatus()
    }
    
    func clear() {
        CustomLog.debug(category: .VM, "\(#function)")
        self.email = ""
        self.password = ""
    }
    
    func checkStatus() {
        CustomLog.debug(category: .VM, "\(#function)")
        canShowAutoFill = existRememberedCredentialUseCase.execute()
    }
    
    func restorePassword() async {
        CustomLog.debug(category: .VM, "\(#function)")
        do {
            try await restorePasswordUseCase.execute(email: emailToRestore)
        } catch  {
            showError(from: error)
        }
    }
    
    
    private func showError(from error: Error) {
        CustomLog.error(category: .VM, "\(error.localizedDescription)")
        Utils.showError(alertMessage: &alertMessage, showAlert: &showAlert, from: error)
    }
}

