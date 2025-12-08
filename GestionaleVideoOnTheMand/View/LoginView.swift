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
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var model: ViewModel
    @State var email: String = ""
    @State var password : String = ""
    
    var getCheck: Bool{
        if(email.isEmpty){
            loginViewModel.errorMessage = "Il campo email è vuoto"
            return false
        }
        if(!Extensions.isValidEmail(email)){
            loginViewModel.errorMessage = "L'email non è valida"
            return false
        }
        if(password.isEmpty){
            loginViewModel.errorMessage = "Il campo password è vuoto"
            return false
        }
        if(!Extensions.isValidPassword(testStr: password)){
            loginViewModel.errorMessage = "la password non è valida, deve comprendere: Almeno una maiuscola, Almeno un numero, Almeno una minuscola, 8 caratteri in totale"
            return false
        }
        return true
    }
    
    
    var body: some View {
        VStack{
            Text("Benvenuto in app.")
                .font(.title)
                .padding()
            
            Text("Effettua l'accesso")
                .padding()
            
            TextField("", text: $email)
                .placeholder(when: email.isEmpty, placeholder: {
                    Text("Email")
                        .foregroundColor(.black)
                })
                .padding(5)
                .foregroundColor(.black)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(height: 30)
                .background(Color.white)
                .font(.title3)
                .cornerRadius(5)
                .padding(.leading)
                .padding(.trailing)
            
            SecureField("",text: $password)
                .placeholder(when: password.isEmpty, placeholder: {
                    Text("Password")
                        .foregroundColor(.black)
                })
                .padding(5)
                .foregroundColor(.black)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(height: 30)
                .background(Color.white)
                .font(.title3)
                .cornerRadius(5)
                .padding(.leading)
                .padding(.trailing)
            
            Spacer()
            HStack {
                Spacer()
                Button {
                    if getCheck{
                        Task {
                            guard let id = await loginViewModel.login(email: email, password: password) else {
                                return
                            }
                            //Recupero utente
                            self.model.recuperoUtente(email: email, password: password, id: id) {
                                if(!model.showAlert){
                                    loginViewModel.page = 2
                                }
                            }
                        }
                    }else {
                        loginViewModel.showError = true
                    }
                } label: {
                    Text("Login")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color.green)
                .cornerRadius(10)
                
                Spacer(minLength: 0)
                
                Button {
                    loginViewModel.page = 1
                } label: {
                    HStack {
                        Text("Sign In")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color.orange)
                .cornerRadius(10)
                Spacer()
                
            }
            
            HStack(spacing: 8){
//                MARK: Custom Apple Sign in Button
                HStack{
                    Image(systemName: "applelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .frame(height: 45)
                    Text("Apple Sign in")
                        .font(.callout)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .padding(.horizontal,15)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.black)
                }
                .overlay {
                    SignInWithAppleButton { (request) in
                        loginViewModel.nonce = loginViewModel.randomNonceString()
                        request.requestedScopes = [.email,.fullName]
                        request.nonce = loginViewModel.sha256(loginViewModel.nonce)
                    } onCompletion: { (resut) in
                        switch resut{
                        case .success(let user):
                            print("success")
    //                        do Login With Firebase
                            guard let credental = user.credential as? ASAuthorizationAppleIDCredential else {
                                print("error with firebase")
                                return
                            }
                            loginViewModel.appleAuthenticate(credential: credental)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .blendMode(.overlay)
                }
                .clipped()
                
//                 MARK: Custom Google Sign in Button
//                HStack{
//                    Image("Google")
//                        .resizable()
//                        .renderingMode(.template)
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 25, height: 25)
//                        .frame(height: 45)
//                    Text("Google  Sign in")
//                        .font(.callout)
//                        .lineLimit(1)
//                }
//                .overlay {
////                          MARK: We have native Google Sign in button
////                          It's Simple to integrate Now
//                      if let clientID = FirebaseApp.app()?.options.clientID{
//                          GoogleSignInButton{
//                              GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: NSApplication.shared.rootController()) { user, error in
//                                  if let error = error {
//                                      print(error.localizedDescription)
//                                      return
//                                  }
////                                  MARK: Logging Google User into firebase
//                                  if let user = user{
//                                      loginViewModel.logGoogleUser(user: user)
//                                  }
//                              }
//                          }
//                          .blendMode(.overlay)
//                      }
//
//                  }
//                .clipped()
//                .foregroundColor(.white)
//                .padding(.horizontal,15)
////                .background(content: {
////                    RoundedRectangle(cornerRadius: 10, style: .continuous)
////                        .fill(.black)
////                })
               
            }
            .padding(.leading,-60)
            .frame(maxWidth:.infinity)
            
            Spacer()
            
        }
        .background(Color("Blue").ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(loginViewModel.errorMessage, isPresented: $loginViewModel.showError, actions: {
            Button {
                loginViewModel.showError.toggle()
            } label: {
                Text("OK")
            }
            
        })
        .alert(model.alertMessage, isPresented: $model.showAlert) {
            Button {
                model.showAlert.toggle()
            } label: {
                Text("OK")
            }
            
        }
        
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(LoginViewModel())
            .environmentObject(ViewModel())
    }
}
