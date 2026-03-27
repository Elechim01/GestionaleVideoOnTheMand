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
    //    Memorizzo la password e l'email
    @AppStorage("IDUser") internal var idUser = ""
    @Published var nonce: String = ""
    @Published var email: String = ""
    @Published var password : String = ""
    
    private let loginUseCase: LoginUseCase
    private let restoreSessionUseCase: RestoreSessionUseCase
    private let logoutUseCase: LogoutUseCase
    
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
         logoutUseCase: LogoutUseCase) {
        self.loginUseCase = loginUseCase
        self.restoreSessionUseCase = restoreSessionUseCase
        self.logoutUseCase = logoutUseCase
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
            self.idUser = id
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
            print(error.localizedDescription)
            showError(from: error)
            return false
        }
    }
    
    func logOut() -> Bool{
        do {
            try logoutUseCase.execute()
            self.idUser = ""
            return true
            
        } catch  {
            showError(from: error)
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

/*
extension LoginHomeViewModel {
    
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
*/
