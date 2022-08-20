//
//  LoginView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI

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
            
            TextField("Email", text: $email)
                .padding(5)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(height: 30)
                .background(Color.white)
                .font(.title3)
                .cornerRadius(5)
                .padding(.leading)
                .padding(.trailing)
            
            SecureField("Password",text: $password)
                .padding(5)
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
                        loginViewModel.login(email: email, password: password, completition: {id in
                            if(!id.isEmpty){
                                
                                //Recupero utente
                                self.model.recuperoUtente(email: email, password: password, id: id) {
                                    if(!model.showAlert){
                                        loginViewModel.page = 2
                                    }
                                }
                            }
                        })
                    }
                    else{
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
    }
}
