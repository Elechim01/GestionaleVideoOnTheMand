//
//  InfoUserView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 31/07/23.
//

import SwiftUI
import LocalAuthentication

struct InfoUserView: View {
    
    @EnvironmentObject var model: HomeViewModel
    @Environment(\.isPreview) var isPreview
    @State var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("info.user")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal,3)
            InfoElement(description: "user.name".localized(), element: model.localUser?.nome)
            InfoElement(description: "user.surname".localized(), element: model.localUser?.cognome)
            InfoElement(description: "user.cell".localized(), element: model.localUser?.cellulare)
            InfoElement(description: "user.email".localized(), element: model.localUser?.email)
            PasswordElement()
            
            Spacer()
        }
        .frame(maxWidth: 250, maxHeight: 250)
        .alert(model.alertMessage, isPresented: $model.showAlert, actions: {
            Button("system.alert.ok",role: .cancel) {
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
        
       ( Text(description)
            .fontWeight(.bold)
         +
        Text(": \(element ?? "")"))
            .font(.body)
            .padding(.horizontal,3)
            .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func PasswordElement() -> some View {
        HStack(alignment: .center) {
                if showPassword {
                    InfoElement(description: "user.password".localized( ), element: model.localUser?.password ?? "")
                } else {
                    InfoElement(description: "user.password".localized(), element: "*******")
                }
            
            SimpleButton(color: .clear, action: {
               
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
            .frame(width: 30)
            
        }
    }
    
}

struct InfoUserView_Previews: PreviewProvider {
    static var previews: some View {
        InfoUserView()
            .environmentObject(PreviewDependecyInjection.shared.makeHomeViewModel())
    }
}
