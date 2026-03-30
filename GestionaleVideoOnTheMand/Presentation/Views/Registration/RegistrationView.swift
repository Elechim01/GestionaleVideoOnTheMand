//
//  RegistrationView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 14/08/22.
//

import SwiftUI
import Services

struct RegistrationView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    @ObservedObject var registrationHomeViewModel: RegistrationHomeViewModel
    
    init(coordinator: Coordinator) {
        self.registrationHomeViewModel = coordinator.registrationHomeViewModel
    }
    
    var body: some View {
        VStack{
           
            Text("system.singIn.title")
                .font(.title)
            
            customTextfield(title: "Nome",
                            value: $coordinator.registrationHomeViewModel.nome)
            customTextfield(title: "Cognome",
                            value: $coordinator.registrationHomeViewModel.cognome)
            customTextfield(title: "Email",
                            value: $coordinator.registrationHomeViewModel.email)
            customTextfield(title: "Pasword",
                            value: $coordinator.registrationHomeViewModel.password,
                            isSecure: true)
            customTextfield(title: "Cellulare",
                            value: $coordinator.registrationHomeViewModel.cellulare)
            
            HStack {
                
                Button {
                    coordinator.goToLogin()
                } label: {
                    Text("system.login.button")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color("Blue"))
                .cornerRadius(10)
                .padding()

                Button {
                    //Registra utente e passa alla home
                    Task {
                        await coordinator.registration()
                    }
                } label: {
                    Text("system.singIn.button")
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100, height: 40)
                .background(Color.green)
                .cornerRadius(10)
                .padding()
            }
            Spacer()
            
        }
        .containerBackground(.ultraThinMaterial, for: .window)
       
        .background(Color("Blue").ignoresSafeArea())
        .alert(registrationHomeViewModel.alertMessage, isPresented: $registrationHomeViewModel.showAlert) {
            Button {
                registrationHomeViewModel.showAlert.toggle()
            } label: {
                Text("system.alert.ok")
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
        RegistrationView(coordinator: Coordinator())
            .environmentObject(Coordinator())
    }
}
