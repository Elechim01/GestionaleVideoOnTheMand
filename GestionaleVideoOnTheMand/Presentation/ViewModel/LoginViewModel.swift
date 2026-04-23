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
class LoginHomeViewModel: ObservableObject {
    
    @Published var showAlert : Bool = false
    @Published var alertMessage : String = ""
    @Published var email: String = ""
    @Published var password : String = ""
    
    private let loginUseCase: LoginUseCase
    private let restoreSessionUseCase: RestoreSessionUseCase
    private let logoutUseCase: LogoutUseCase
    private let sessionManager: SessionManager
    
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
    
    init(loginUseCase: LoginUseCase,
         restoreSessionUseCase: RestoreSessionUseCase,
         logoutUseCase: LogoutUseCase,
         sessionManager: SessionManager) {
        self.loginUseCase = loginUseCase
        self.restoreSessionUseCase = restoreSessionUseCase
        self.logoutUseCase = logoutUseCase
        self.sessionManager = sessionManager
    }
    
    
    //    Funzioni di Login e Logout
    func login() async  -> Bool {
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
        do {
            try logoutUseCase.execute()
            sessionManager.clearSession()
            return true
            
        } catch  {
            showError(from: error)
            return false
        }
    }
    
    
    private func showError(from error: Error) {
        CustomLog.error(category: .VM, "\(error.localizedDescription)")
        Utils.showError(alertMessage: &alertMessage, showAlert: &showAlert, from: error)
    }
}

