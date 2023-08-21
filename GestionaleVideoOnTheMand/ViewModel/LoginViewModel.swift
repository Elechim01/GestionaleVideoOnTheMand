//
//  LoginViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Firebase
import AuthenticationServices
import GoogleSignIn
import CryptoKit
class LoginViewModel: ObservableObject{
    
    //    Page: 0 -> Login, 1->Registration ,2 -> Home
    @AppStorage("Pagina") internal var  page : Int = 0
    
    var pagina: Page {
        switch page {
        case 0:
            return .Login
        case 1:
            return .Registration
        case 2:
            return .Home
        default:
            return .Login
        }
    }
    
    @Published var showError : Bool = false
    @Published var errorMessage : String = ""
    
    //    Memorizzo la password e l'email
    @AppStorage("Password") internal var password = ""
    @AppStorage("Email") internal var email = ""
    @AppStorage("IDUser") internal var idUser = ""
    @Published var nonce: String = ""
    
    //    Funzioni di Login e Logout
    func login(email: String, password: String, completition : @escaping (String)->()){
        if(!Extensions.isConnectedToInternet()){
            errorMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showError.toggle()
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
            guard let self = self else { return }
            if let err = error{
                print(err.localizedDescription)
                self.errorMessage = err.localizedDescription
                self.showError.toggle()
                completition("")
                return
            }else{
                guard let authResult = authResult else { return }
                //                Salvo i valori per renderli permanenti
                let attributes: [String : Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: email,
                    kSecValueData as String: password.data(using: .utf8)!
                ]
                Task(priority: .background) {
                    if SecItemAdd(attributes as CFDictionary, nil) == noErr {
                        print("User saved succes")
                    } else {
                        print("Error")
                    }
                    
                }
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
        } catch let singoutError as NSError {
            print("Error %@",singoutError)
        }
        self.email = ""
        self.password = ""
        self.idUser = ""
        page = 0
    }
    
    //    Funzione di Registrazione
    func registration(email:String, password: String,completion:@escaping (String) ->()){
        if(!Extensions.isConnectedToInternet()){
            errorMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showError.toggle()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password){[weak self] authResult,error in
            guard let self = self else { return }
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
    
    //    MARK: Apple Sign in API
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential){
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        //        token String...
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: tokenString,rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { result, err in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            print("Logged in Success")
            withAnimation(.easeInOut){
                //                    self.logStatus = true
            }
        }
        
        
    }
    
    //    MARK: Logging Google User into firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                guard let idToken = user.authentication.idToken else{return}
                let accessToken = user.authentication.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                try await Auth.auth().signIn(with: credential)
                print("Ya fatta !")
                await MainActor.run(body: {
                    withAnimation(.easeInOut){
                        
                    }
                })
            }catch{
                
            }
        }
    }
    
    
    //MARK: Apple Sign in Hepers
    func sha256(_ input: String) -> String {
     let inputData = Data(input.utf8)
     let hashedData = SHA256.hash(data: inputData)
     let hashString = hashedData.compactMap {
       return String(format: "%02x", $0)
     }.joined()

     return hashString
    }
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func randomNonceString(length: Int = 32) -> String {
     precondition(length > 0)
     let charset: Array<Character> =
         Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
     var result = ""
     var remainingLength = length

     while remainingLength > 0 {
       let randoms: [UInt8] = (0 ..< 16).map { _ in
         var random: UInt8 = 0
         let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
         if errorCode != errSecSuccess {
           fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
         }
         return random
       }

       randoms.forEach { random in
         if remainingLength == 0 {
           return
         }

         if random < charset.count {
           result.append(charset[Int(random)])
           remainingLength -= 1
         }
       }
     }

     return result
    }
}

extension NSApplication{
    
//    Root Controller
    func rootController() -> NSViewController {
        guard let window =  windows.first as? NSWindow else { return .init() }
        guard let viewController = window.contentViewController else {return .init()}
//                rootViewController else { return .init() }
        
        return viewController
    }
}



