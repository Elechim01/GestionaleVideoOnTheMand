//
//  LoginViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Firebase
class LoginViewModel: ObservableObject{
    
    //    Page: 0 -> Login, 1->Registration ,2 -> Home
    @AppStorage("Pagina") var page : Int = 0
    @Published var showError : Bool = false
    @Published var errorMessage : String = ""
    
    //    Memorizzo la password e l'email
    @AppStorage("Password") var password = ""
    @AppStorage("Email") var email = ""
    @AppStorage("IDUser") var idUser = ""
    
    //    Funzioni di Login e Logout
    func login(email: String, password: String, completition : @escaping (String)->()){
        if(!Extensions.isConnectedToInternet()){
            errorMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showError.toggle()
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){authResult,error in
            
            if let err = error{
                print(err.localizedDescription)
                self.errorMessage = err.localizedDescription
                self.showError.toggle()
                completition("")
                return
            }else{
                guard let authResult = authResult else { return }
//                Salvo i valori per renderli permanenti
                self.password = password
                self.email = email
                self.idUser = authResult.user.uid
                completition(authResult.user.uid)
                
                return
            }
        }
        
    }
    
    func logOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
//               svuoto i valori
            self.email = ""
            self.password = ""
            self.idUser = ""
            page = 0
        } catch let singoutError as NSError {
            print("Error %@",singoutError)
        }
    }
    
    //    Funzione di Registrazione
    func registration(email:String, password: String,completion:@escaping (String) ->()){
        if(!Extensions.isConnectedToInternet()){
            errorMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showError.toggle()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password){authResult,error in
            if let error = error{
                print(error.localizedDescription)
                self.errorMessage = error.localizedDescription
                self.showError.toggle()
                completion("")
                return
            }else{
                guard let authResult = authResult else {
                    return
                }
                print(authResult.user.uid)
//                Salvo i valori per renderli permanenti
                self.email = email
                self.password = password
                self.idUser = authResult.user.uid
                completion(authResult.user.uid)
                return
            }
        }
    }
}
