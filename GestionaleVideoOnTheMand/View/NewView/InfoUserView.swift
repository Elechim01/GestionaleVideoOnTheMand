//
//  InfoUserView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 31/07/23.
//

import SwiftUI
import LocalAuthentication

struct InfoUserView: View {
    
    @EnvironmentObject var model: ViewModel
    @Environment(\.isPreview) var isPreview
    @State var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Info Utente:")
                .font(.title)
                .padding(.horizontal,3)
            InfoElement(description: "Nome", element: model.localUser?.nome)
            InfoElement(description: "Cognome", element: model.localUser?.cognome)
            InfoElement(description: "Cellulare", element: model.localUser?.cellulare)
            InfoElement(description: "E-mail", element: model.localUser?.email)
            PasswordElement()
            Spacer()
        }
        .frame(maxWidth: 250, maxHeight: 200)
        .alert(model.alertMessage, isPresented: $model.showAlert, actions: {
            Button("OK",role: .cancel) {
                model.showAlert.toggle()
            }
        })
        .onAppear {
            if isPreview {
                model.localUser = previewUser
            }
        }
    }
    
    @ViewBuilder
    func InfoElement(description: String, element: String?) -> some View {
        Text("\(description): \(element ?? "")")
            .font(.body)
            .padding(.horizontal,3)
            .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func PasswordElement() -> some View {
        HStack(alignment: .center) {
                if showPassword {
                    Text("Password: \(model.localUser?.password ?? "")")
                } else {
                    Text("Password: *********")
                        .padding(.vertical,5)
                        .padding(.top,5)
                }
            
            CustomButton(falseColor: .clear, action: {
               
                if !showPassword {
                    model.authenticate { response in
                        if response {
                            showPassword.toggle()
                        }
                    }
                } else {
                    showPassword.toggle()
                }
            }, label: {
                if !showPassword {
                    Image(systemName: "eye.fill")
                } else {
                    Image(systemName: "eye.slash.fill")
                }
            })
            .frame(width: 50)
            
        }
    }
    
   
    
}

struct InfoUserView_Previews: PreviewProvider {
    static var previews: some View {
        InfoUserView()
            .environmentObject(ViewModel())
    }
}
