//
//  RegistrationView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Services

struct RegistrationView: View {
    @EnvironmentObject var loginModel: LoginViewModel
    @EnvironmentObject var model: ViewModel
    
    
    var checkCampi: Bool{
//        Controllo nome:
        if nome.isEmpty {
            loginModel.alertMessage = "Il campo nome è vuoto"
            return false
        }
        if cognome.isEmpty {
            loginModel.alertMessage = "Il campo cognome è vuoto"
            return false
        }
        if email.isEmpty {
            loginModel.alertMessage = "Il campo email è vuoto"
            return false
        }
        if !Utils.isValidEmail(email){
            loginModel.alertMessage = "L'email non è valida"
            return false
        }
        if password.isEmpty{
            loginModel.alertMessage = "Il campo password è vuoto"
            return false
        }
        if !Utils.isValidPassword(testStr: password){
            loginModel.alertMessage = "la password non è valida, deve comprendere: Almeno una maiuscola, Almeno un numero, Almeno una minuscola, 8 caratteri in totale"
            return false
        }
        if cellulare.isEmpty{
            loginModel.alertMessage = "Il campo cellulare è vuoto"
            return false
        }
        if Int(cellulare) == nil{
            loginModel.alertMessage = "Il valore non è un numero"
            return false
        }
        
        return true
    }
    
    @State var nome: String = ""
    @State var cognome: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var cellulare: String = ""
    
    
    var body: some View {
        VStack{
           
            Text("Registrati...")
                .font(.title)
            
            customTextfield(title: "Nome", value: $nome)
            customTextfield(title: "Cognome", value: $cognome)
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
                        Task {
                            var utente = Utente(id: "", nome: self.nome, cognome: self.cognome, email: self.email, password: self.password, cellulare: self.cellulare)
                            try  await FirebaseUtils.shared.addUtente(utente: utente)
                            loginModel.registration(email: utente.email, password: utente.password, completion: { id in
                                if(!id.isEmpty){
                                    utente.id = id
                                    print("Utente:\(utente.id)")
                                    model.localUser = utente
                                    loginModel.page = 2
                                }
                            })
                        }
                       
                        
    //                    Registra utente e passa alla home
                        
                    } else {
                        loginModel.showAlert = true
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
        .alert(loginModel.alertMessage, isPresented: $loginModel.showAlert) {
            Button {
                loginModel.showAlert.toggle()
            } label: {
                Text("OK")
            }
        }
    }
    
    @ViewBuilder
    func customTextfield (title: String, value: Binding<String>, isSecure: Bool = false ) -> some View {
        if(isSecure){
            SecureField(title, text: value)
                .placeholder(when:  value.wrappedValue.isEmpty , placeholder: {
                    Text(title)
                        .foregroundColor(.black)
                })
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
                .placeholder(when:  value.wrappedValue.isEmpty , placeholder: {
                    Text(title)
                        .foregroundColor(.black)
                })
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
