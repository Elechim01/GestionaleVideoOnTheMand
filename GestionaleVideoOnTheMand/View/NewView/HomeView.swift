//
//  NewHome.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var homeViewModel: ViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var columsVisibility = NavigationSplitViewVisibility.all
    @Environment(\.openWindow) var openWindow
    @State var homeSection: HomeSection = .spazio
    @State var showLogoutConfirm: Bool = false
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columsVisibility) {
            
            VStack(alignment: .leading) {
                
                InfoUser(name: homeViewModel.localUser?.nome ?? "TEST")
                
                ListButton(text: "Film", imageName: "film",section: .film, onTap: nil)
                
                
                ListButton(text: "Spazio", imageName: "opticaldiscdrive",section: .spazio, onTap: nil)
                
                Spacer()
            }
            .padding(.horizontal,5)
            
        } detail: {
            ZStack(alignment: .center) {
                switch homeSection {
                case .film:
                    FilmView()
                        .environmentObject(homeViewModel)
                case .spazio:
                    StorageView()
                        .environmentObject(homeViewModel)
                }
                
                if homeViewModel.showAlert {
                    ProgressView()
                }
            }
            
        }
        .frame(minWidth: 300, idealWidth: 600, maxWidth: .infinity, minHeight: 400, idealHeight: 700, maxHeight: .infinity)
        .containerBackground(.ultraThinMaterial, for: .window)
        .navigationSplitViewStyle(.balanced)
        .alert(homeViewModel.alertMessage, isPresented: $homeViewModel.showAlert, actions: {
            Button("OK",role: .cancel) {
                homeViewModel.showAlert.toggle()
            }
        })
        .alert("Sei sicuro di voler fare Logout", isPresented: $showLogoutConfirm,actions: {
            Button("Annulla", role: .cancel) {
                showLogoutConfirm.toggle()
            }
            Button("Conferma", role: .destructive) {

                Task(priority: .background) {
                    loginViewModel.logOut()
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
        
        CustomButton(isActive: homeSection == section ,
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
        SimpleButton(color: .green.opacity(0.6), action: {
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
        
        SimpleButton(color: .white, action: {
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
            .padding(.top)
    }
    
}

struct NewHome_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .frame(width: 900, height: 600)
            .environmentObject(ViewModel())
            .environmentObject(LoginViewModel())
    }
}


