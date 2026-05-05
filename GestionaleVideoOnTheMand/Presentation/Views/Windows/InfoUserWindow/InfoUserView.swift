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
    
   // @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.isPreview) var isPreview
    @State var showPassword: Bool = false
    @State var decryptedEmail: String = ""
    @State var decriptedPassword: String = ""
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("info.user")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal,3)
            InfoElement(description: "user.name".localized(), element: sessionManager.currentUser?.nome)
            InfoElement(description: "user.surname".localized(), element: sessionManager.currentUser?.cognome)
            InfoElement(description: "user.cell".localized(), element: sessionManager.currentUser?.cellulare)
            InfoElement(description: "user.email".localized(), element: decryptedEmail)
            PasswordElement()
            
            Spacer()
        }
        .frame(maxWidth: 250, maxHeight: 250)
        .onAppear {
            if isPreview {
                sessionManager.currentUser = Mock.previewUser
            }
            decryptedEmail = sessionManager.getSecureEmail() ?? ""
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
                InfoElement(description: "user.password".localized( ), element: decriptedPassword)
            } else {
                InfoElement(description: "user.password".localized(), element: "*******")
            }
            
            SimpleButton(color: .clear, action: {
                if !showPassword {
                    
                    self.decriptedPassword = sessionManager.getSecurePassword() ?? ""
                    self.showPassword = true
                    
                } else {
                    self.showPassword.toggle()
                    self.decriptedPassword = ""
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
            .environmentObject(SessionManager())
    }
}
