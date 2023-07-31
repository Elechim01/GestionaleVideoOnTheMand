//
//  ContentView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
struct ContentView: View {
    
  
    @EnvironmentObject var model: ViewModel
    @StateObject var login = LoginViewModel()
    
    var body: some View {
        if(login.pagina == .Login){
            LoginView()
                .environmentObject(login)
                .environmentObject(model)
        }else if(login.pagina == .Registration){
            RegistrationView()
                .environmentObject(login)
                .environmentObject(model)
        }else if(login.pagina == .Home){
            
            #if DEV
             NewHome()
            #else
            HomeView()
                  .environmentObject(model)
                  .environmentObject(login)
            #endif
        }else{
            Text("Page not found")
        }
     
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
