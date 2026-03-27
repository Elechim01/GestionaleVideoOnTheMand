//
//  RegistrationHomeViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/03/26.
//

import Foundation
import SwiftUI
import Services
import ElechimCore


@MainActor
class RegistrationHomeViewModel: ObservableObject {
    @Published var nome: String = ""
    @Published var cognome: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var cellulare: String = ""
    
    @Published var showAlert : Bool = false
    @Published var alertMessage : String = ""
    
    @AppStorage("IDUser") internal var idUser = ""
    
    private let registrationUseCase: RegistrationUseCase
    
    init(registrationUseCase: RegistrationUseCase) {
        self.registrationUseCase = registrationUseCase
    }
    
    var checkCampi: Bool{
        //        Controllo nome:
        if nome.isEmpty {
            alertMessage = "Il campo nome è vuoto"
            return false
        }
        if cognome.isEmpty {
            alertMessage = "Il campo cognome è vuoto"
            return false
        }
        if email.isEmpty {
            alertMessage = "Il campo email è vuoto"
            return false
        }
        if !Utils.isValidEmail(email){
            alertMessage = "L'email non è valida"
            return false
        }
        if password.isEmpty{
            alertMessage = "Il campo password è vuoto"
            return false
        }
        if !Utils.isValidPassword(testStr: password){
            alertMessage = "la password non è valida, deve comprendere: Almeno una maiuscola, Almeno un numero, Almeno una minuscola, 8 caratteri in totale"
            return false
        }
        if cellulare.isEmpty{
            alertMessage = "Il campo cellulare è vuoto"
            return false
        }
        if Int(cellulare) == nil{
            alertMessage = "Il valore non è un numero"
            return false
        }
        
        return true
    }
    
    
    func registration() async -> Bool {
        
        do {
            guard checkCampi else  {
                self.showAlert.toggle()
                return false
            }
            guard Utils.isConnectedToInternet() else {
                throw CustomError.connectionError
            }
           let idUser =  try await registrationUseCase.execute(nome: nome,
                                            cognome: cognome,
                                            email: email,
                                            password: password,
                                            cellulare: cellulare)
            self.idUser = idUser
            return true
        } catch  {
            self.showError(from: error)
            return false
        }
    }
    
    private func showError(from error: Error) {
        if let custom = error as? CustomError {
            alertMessage = custom.description
        } else if let apiError = error as? ApiError {
            alertMessage = apiError.error.localizedDescription
        } else {
            alertMessage = "Generic Error"
        }
        self.showAlert.toggle()
    }
}
