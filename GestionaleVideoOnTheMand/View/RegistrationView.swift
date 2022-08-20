//
//  RegistrationView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var loginModel: LoginViewModel
    @EnvironmentObject var model: ViewModel
    
    
    var checkCampi: Bool{
//        Controllo nome:
        if nome.isEmpty {
            loginModel.errorMessage = "Il campo nome è vuoto"
            return false
        }
        if cognome.isEmpty {
            loginModel.errorMessage = "Il campo cognome è vuoto"
            return false
        }
        if eta.isEmpty{
            loginModel.errorMessage = "Il campo età è vuto"
            return false
        }
        if(Int(eta) == nil){
            loginModel.errorMessage = "Il campo età non è un numero"
            return false
        }
        if email.isEmpty {
            loginModel.errorMessage = "Il campo email è vuoto"
            return false
        }
        if !Extensions.isValidEmail(email){
            loginModel.errorMessage = "L'email non è valida"
            return false
        }
        if password.isEmpty{
            loginModel.errorMessage = "Il campo password è vuoto"
            return false
        }
        if !Extensions.isValidPassword(testStr: password){
            loginModel.errorMessage = "la password non è valida, deve comprendere: Almeno una maiuscola, Almeno un numero, Almeno una minuscola, 8 caratteri in totale"
            return false
        }
        if cellulare.isEmpty{
            loginModel.errorMessage = "Il campo cellulare è vuoto"
            return false
        }
        if Int(cellulare) == nil{
            loginModel.errorMessage = "Il valore non è un numero"
            return false
        }
        
        return true
    }
    
    @State var nome: String = ""
    @State var cognome: String = ""
    @State var eta: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var cellulare: String = ""
    
    
    var body: some View {
        VStack{
           
            Text("Registrati...")
                .font(.title)
            
            customTextfield(title: "Nome", value: $nome)
            customTextfield(title: "Cognome", value: $cognome)
            customTextfield(title: "Età", value: $eta)
            customTextfield(title: "Email", value: $email)
            customTextfield(title: "Pasword", value: $password,isSecure: true)
            customTextfield(title: "Cellulare", value: $cellulare)
            
            HStack {
                
                
                Button {
                    loginModel.page = 0
                } label: {
                    Text("Login")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color("Blue"))
                .cornerRadius(10)
                .padding()

                
                Button {
                    if checkCampi {
    //                    Creo utente
//                        #warning("implementare controllo utente, se si sta registrando 2 volte")
                        var utente = Utente(id: "", nome: self.nome, cognome: self.cognome, età: Int(self.eta)!, email: self.email, password: self.password, cellulare: self.cellulare)
                        model.addUtente(utente: utente)
                       
                      
    //                    Registra utente e passa alla home
                        loginModel.registration(email: utente.email, password: utente.password, completion: { id in
                            if(!id.isEmpty){
                                utente.id = id
                                print("Utente:\(utente.id)")
                                model.localUser = utente
                                loginModel.page = 2
                            }
                            
                        })
                        
                    }else{
                        loginModel.showError = true
                    }
                } label: {
                    Text("Registrati")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color.green)
                .cornerRadius(10)
                .padding()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
            Button {
                loginModel.showError.toggle()
            } label: {
                Text("OK")
            }

        }
    }
    
    
    @ViewBuilder
    func customTextfield (title: String, value: Binding<String>, isSecure: Bool = false ) -> some View {
        if(isSecure){
            SecureField(title, text: value)
                .padding(5)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(height: 30)
                .background(Color.white)
                .font(.title3)
                .cornerRadius(5)
                .padding(.leading)
                .padding(.trailing)
        }else{
          TextField(title, text: value)
                .padding(5)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(height: 30)
                .background(Color.white)
                .font(.title3)
                .cornerRadius(5)
                .padding(.leading)
                .padding(.trailing)
        }
        
        
    }
    
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(LoginViewModel())
            .environmentObject(ViewModel())
    }
}
