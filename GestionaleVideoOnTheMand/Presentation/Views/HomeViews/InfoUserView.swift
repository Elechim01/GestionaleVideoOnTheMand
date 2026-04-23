//
//  InfoUserView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 31/07/23.
//

import SwiftUI
import LocalAuthentication
import Services

struct InfoUserView: View {
    
    @EnvironmentObject var viewModel: HomeViewModel
    @Environment(\.isPreview) var isPreview
    @State var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("info.user")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal,3)
            InfoElement(description: "user.name".localized(), element: viewModel.sessionManager.currentUser?.nome)
            InfoElement(description: "user.surname".localized(), element: viewModel.sessionManager.currentUser?.cognome)
            InfoElement(description: "user.cell".localized(), element: viewModel.sessionManager.currentUser?.cellulare)
            InfoElement(description: "user.email".localized(), element: viewModel.sessionManager.currentUser?.email)
            PasswordElement()
            
            Spacer()
        }
        .frame(maxWidth: 250, maxHeight: 250)
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert, actions: {
            Button("system.alert.ok",role: .cancel) {
                viewModel.showAlert.toggle()
            }
        })
        .onAppear {
            if isPreview {
                viewModel.sessionManager.currentUser = Mock.previewUser
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
                    InfoElement(description: "user.password".localized( ), element: viewModel.sessionManager.currentUser?.password ?? "")
                } else {
                    InfoElement(description: "user.password".localized(), element: "*******")
                }
            
            SimpleButton(color: .clear, action: {
               
                if !showPassword {
                    viewModel.authenticate { response in
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
