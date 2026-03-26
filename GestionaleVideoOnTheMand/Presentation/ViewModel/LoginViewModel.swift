//
//  LoginViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Services
import Firebase
import AuthenticationServices
import GoogleSignIn
import CryptoKit

@MainActor
class LoginViewModel: ObservableObject {
    
    //    Page: 0 -> Login, 1->Registration ,2 -> Home
    @AppStorage("Pagina") internal var  page : Int = 0
    @Published var showAlert : Bool = false
    @Published var alertMessage : String = ""
    //    Memorizzo la password e l'email
    @AppStorage("IDUser") internal var idUser = ""
    @Published var nonce: String = ""
    
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
    
    private let loginUseCase: LoginUseCase
    private let restoreSessionUseCase: RestoreSessionUseCase
    private let logoutUseCase: LogoutUseCase
    
    init(loginUseCase: LoginUseCase,
         restoreSessionUseCase: RestoreSessionUseCase,
         logoutUseCase: LogoutUseCase) {
        self.loginUseCase = loginUseCase
        self.restoreSessionUseCase = restoreSessionUseCase
        self.logoutUseCase = logoutUseCase
    }
    
    
    //    Funzioni di Login e Logout
    func login(email: String, password: String) async {
        guard Utils.isConnectedToInternet() else {
            alertMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showAlert.toggle()
            return
        }
        do {
            let id = try await loginUseCase.execute(email: email, password: password)
            self.idUser = id
            self.page = 2
        } catch {
            
            self.showError(from: error)
        }
    }
    
    func restoreSession() async {
        self.page = 0
        do {
            guard  Utils.isConnectedToInternet()  else {
                return  // TODO: CHANGE ERROR TYPE
            }
            let isSessionRestored = try await restoreSessionUseCase.execute()
            
            if isSessionRestored {
                self.page = 2
            } else {
                self.page = 0
            }
        } catch {
            print(error.localizedDescription)
            showError(from: error)
            self.page = 0
        }
    }
    
    func logOut(){
        do {
            try logoutUseCase.execute()
            self.idUser = ""
            page = 0
            
        } catch  {
            showError(from: error)
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


extension LoginViewModel {
    #warning("Move to Async/Await")
    //    Funzione di Registrazione
    func registration(email:String, password: String,completion: @escaping (String) ->()){
        if(!Utils.isConnectedToInternet()){
            alertMessage = "Impossibile effettuare il login in assenza di connessione internet"
            showAlert.toggle()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password){[weak self] authResult,error in
            guard let self = self else { return }
            if let error = error{
                print(error.localizedDescription)
                self.alertMessage = error.localizedDescription
                self.showAlert.toggle()
                completion("")
                return
            }else{
                guard let authResult = authResult else {
                    return
                }
                print(authResult.user.uid)
                //  Salvo i valori per renderli permanenti
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
        // self.logStatus = true
            }
        }
        
        
    }
    
    //    MARK: Logging Google User into firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                guard let idToken = user.idToken?.tokenString else{return}
                let accessToken = user.accessToken.tokenString
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

