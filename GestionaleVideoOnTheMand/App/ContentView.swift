//
//  ContentView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
#warning("Add coordinator")
struct ContentView: View {
    
    @EnvironmentObject var homeModel: ViewModel
    @EnvironmentObject var login: LoginViewModel
    
    var body: some View {
        Group {
            if login.pagina == .Login {
                LoginView()
            } else if login.pagina == .Registration {
                RegistrationView()
            } else if login.pagina == .Home {
                HomeView()
            } else {
                Text("Page not found")
            }
        }
        .environmentObject(login)
        .environmentObject(homeModel)
        .onChange(of: login.pagina) { newPagina in
            if newPagina == .Home {
                Task {
                    await homeModel.start()
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {       
        ContentView()
            .environmentObject(PreviewDependecyInjection.shared.makeViewModel())
            .environmentObject(PreviewDependecyInjection.shared.makeLoginViewModel())
    }
}
