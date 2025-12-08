//
//  NewHome.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ViewModel
    @EnvironmentObject var loginModel: LoginViewModel
    @State private var columsVisibility = NavigationSplitViewVisibility.all
    @Environment(\.openWindow) var openWindow
    @State var homeSection: HomeSection = .film
    @State var showLogoutConfirm: Bool = false
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columsVisibility) {
            
            VStack(alignment: .leading) {
                
                InfoUser(name: model.localUser?.nome ?? "")
                
                ListButton(text: "Film", imageName: "film",section: .film, onTap: nil)
                
                
                ListButton(text: "Spazio", imageName: "opticaldiscdrive",section: .spazio, onTap: nil)
                
                Spacer()
            }
            
        } detail: {
            switch homeSection {
            case .film:
                FilmView()
                    .environmentObject(model)
            case .spazio:
                StorageView()
                    .environmentObject(model)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .alert(model.alertMessage, isPresented: $model.showAlert, actions: {
            Button("OK",role: .cancel) {
                model.showAlert.toggle()
            }
        })
        .alert("Sei sicuro di voler fare Logout", isPresented: $showLogoutConfirm,actions: {
            Button("Annulla", role: .cancel) {
                showLogoutConfirm.toggle()
            }
            Button("Conferma", role: .destructive) {

                Task(priority: .background) {
                    loginModel.logOut()
                }
                showLogoutConfirm.toggle()
            }
        })
    }
    
    @ViewBuilder
    func ListButton(text: String,
                    imageName: String,
                    section: HomeSection,
                    onTap: (()->())?
    ) -> some View {
        
        CustomButton(condition: homeSection == section ,
                     trueColor: .blue,
                     falseColor: .clear,
                     action: {
            homeSection = section
            onTap?()
        },label: {
            HStack(alignment: .center) {
                Image(systemName: imageName)
                    .padding(.leading,5)
                Text(text)
                Spacer()
            }
        })
    }
    
    @ViewBuilder
    func InfoUser(name: String) -> some View {
        CustomButton(falseColor: .green.opacity(0.6), action: {
            openWindow(id:"infoUser")
        }, label: {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.black)
                    .padding(.leading,5)
                Text("\(name)")
                    .foregroundColor(.black)
                Spacer()
            }
        })
        
        CustomButton(falseColor: .white, action: {
            showLogoutConfirm.toggle()
        }, label: {
            
            HStack {
                Image(systemName: "escape")
                    .foregroundColor(.black)
                    .padding(.leading,5)
                Text("Logout")
                    .foregroundColor(.black)
                Spacer()
            }
        })
        
        Divider()
    }
    
}

struct NewHome_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ViewModel())
            .environmentObject(LoginViewModel())
    }
}


