//
//  LoginView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct LoginView: View {
    
    @EnvironmentObject var coordinator: Coordinator
    
    @ObservedObject var loginHomeViewModel: LoginHomeViewModel
    
    init(coordinator: Coordinator) {
        self.loginHomeViewModel = coordinator.loginHomeViewModel
    }
    
    var body: some View {
        VStack {
            Text("system.welcome.to.app")
                .font(.title)
                .padding()
            
            Text("system.load.access")
                .padding()
            
            TextField("", text: $loginHomeViewModel.email)
                .placeholder(when: loginHomeViewModel.email.isEmpty) {
                    Text("system.email").foregroundColor(.black)
                }
                .modifier(LoginTextFieldStyle())
            
            SecureField("", text: $loginHomeViewModel.password)
                .placeholder(when: loginHomeViewModel.password.isEmpty) {
                    Text("system.password").foregroundColor(.black)
                }
                .modifier(LoginTextFieldStyle())
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    Task {
                        await coordinator.login()
                    }
                } label: {
                    Text("system.login.button")
                }
                .modifier(LoginButtonStyle(color: .green))
                
                Spacer(minLength: 0)
                
                // BOTTONE REGISTRAZIONE
                Button {
                    coordinator.goToRegistration()
                } label: {
                    HStack {
                        Text("system.singIn.button")
                        Image(systemName: "arrow.right")
                    }
                }
                .modifier(LoginButtonStyle(color: .orange))
                
                Spacer()
            }
            
            // APPLE SIGN IN
           // appleSignInSection
            
            Spacer()
        }
        .background(Color("Blue").ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ALERT collegati ai HomeViewModel nel Coordinator
        .alert(loginHomeViewModel.alertMessage, isPresented: $loginHomeViewModel.showAlert) {
            Button("system.alert.ok") { loginHomeViewModel.showAlert = false }
        }
    }
    
    // MARK: - Sottoviste per pulizia
    /*
    private var appleSignInSection: some View {
        HStack {
            SignInWithAppleButton { request in
                loginHomeViewModel.nonce = loginHomeViewModel.randomNonceString()
                request.requestedScopes = [.email, .fullName]
                request.nonce = loginHomeViewModel.sha256(loginHomeViewModel.nonce)
            } onCompletion: { result in
                switch result {
                case .success(let user):
                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else { return }
                    loginHomeViewModel.appleAuthenticate(credential: credential)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 55)
            .frame(width: 200) // Regola secondo le tue esigenze su Mac
        }
        .padding(.top)
    }
     */
}

// MARK: - Helper per pulire la UI (facoltativo ma consigliato)
struct LoginTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(5)
            .foregroundColor(.black)
            .textFieldStyle(PlainTextFieldStyle())
            .frame(height: 30)
            .background(Color.white)
            .font(.title3)
            .cornerRadius(5)
            .padding(.horizontal)
    }
}

struct LoginButtonStyle: ViewModifier {
    var color: Color
    func body(content: Content) -> some View {
        content
            .buttonStyle(PlainButtonStyle())
            .frame(width: 100, height: 40)
            .background(color)
            .cornerRadius(10)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(coordinator: Coordinator())
            .environmentObject(Coordinator())
    }
}
