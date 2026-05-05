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
    
    @ObservedObject var loginViewModel: LoginViewModel
    @State private var showDeleteRememberedCredential: Bool = false
    @State private var isRestoreSheetPresented: Bool = false
    
    init(coordinator: Coordinator) {
        self.loginViewModel = coordinator.loginViewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("system.welcome.to.app")
                    .font(.title)
                    .bold()
                
                Text("system.load.access")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            VStack(spacing: 15) {
                TextField("system.email", text: $loginViewModel.email)
                    .modifier(LoginTextFieldStyle())
                    .textContentType(.username) // Aiuta il sistema
                    .disableAutocorrection(true)
                
                SecureField("system.password", text: $loginViewModel.password)
                    .modifier(LoginTextFieldStyle())
                    .textContentType(.password)
            }
            .padding(.horizontal)
            
            Button("Passowrd dimenticata ?") {
                isRestoreSheetPresented = true
            }
            .font(.body)
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            
            
            // Sezione Credenziali Ricordate
            
            HStack(spacing: 12) {
                if loginViewModel.canShowAutoFill {
                    Button {
                        loginViewModel.loadRememberCredential()
                    } label: {
                        Label("Usa salvato", systemImage: "key.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .modifier(LoginButtonStyle(color: .brown))
                    .padding(.horizontal)
                }
                Button {
                    showDeleteRememberedCredential.toggle()
                } label: {
                    Image(systemName: "trash")
                        .padding(.horizontal, 10)
                }
                .modifier(LoginButtonStyle(color: .gray,width: 60))
            }
            .padding(.horizontal)
            .transition(.opacity.combined(with: .move(edge: .top)))
            
            
            Spacer()
            
            // Footer Bottoni
            HStack(spacing: 20) {
                Button {
                    Task { await coordinator.login() }
                } label: {
                    Text("system.login.button")
                        .frame(maxWidth: .infinity)
                }
                .modifier(LoginButtonStyle(color: .green))
                
                Button {
                    coordinator.goToRegistration()
                } label: {
                    HStack {
                        Text("system.singIn.button")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                }
                .modifier(LoginButtonStyle(color: .orange))
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color("Blue").ignoresSafeArea())
        .onAppear {
            loginViewModel.clear()
            loginViewModel.checkStatus()
        }
        // Alerts
        .alert(loginViewModel.alertMessage,
               isPresented: $loginViewModel.showAlert) {
            Button("system.alert.ok", role: .cancel) { }
        }
        .alert("Rimuovi credenziali",
               isPresented: $showDeleteRememberedCredential) {
            Button("Annulla", role: .cancel) { }
            Button("Elimina", role: .destructive) {
                loginViewModel.deleteRememberCredential()
            }
        } message: {
            Text("Le tue credenziali non verranno più inserite automaticamente al prossimo accesso.")
        }
        .sheet(isPresented: $isRestoreSheetPresented) {
            RestorePassword()
                .environmentObject(loginViewModel)
        }
        
    }
}
    // MARK: - Sottoviste per pulizia
    /*
    private var appleSignInSection: some View {
        HStack {
            SignInWithAppleButton { request in
                loginViewModel.nonce = loginViewModel.randomNonceString()
                request.requestedScopes = [.email, .fullName]
                request.nonce = loginViewModel.sha256(loginViewModel.nonce)
            } onCompletion: { result in
                switch result {
                case .success(let user):
                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else { return }
                    loginViewModel.appleAuthenticate(credential: credential)
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
    var width: CGFloat = 100
    var height: CGFloat = 40
    func body(content: Content) -> some View {
        content
            .buttonStyle(PlainButtonStyle())
            .frame(width: width, height: height)
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
