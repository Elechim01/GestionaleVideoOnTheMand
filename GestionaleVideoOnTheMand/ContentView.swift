//
//  ContentView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @EnvironmentObject var homeModel: ViewModel
    @EnvironmentObject var login: LoginViewModel
    
    var body: some View {
        Group {
            if login.pagina == .Login {
                LoginView()
                    .environmentObject(login)
                    .environmentObject(homeModel)
            } else if login.pagina == .Registration {
                RegistrationView()
                    .environmentObject(login)
                    .environmentObject(homeModel)
            } else if login.pagina == .Home {
                HomeView()
                    .environmentObject(homeModel)
            } else {
                Text("Page not found")
            }
        }
        .onChange(of: login.pagina) { newPagina in
            if newPagina == .Home {
                Task {
                    await homeModel.loadFilmView()
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
            .environmentObject(LoginViewModel())
    }
}
