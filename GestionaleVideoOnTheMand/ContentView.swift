//
//  ContentView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
struct ContentView: View {
    
  
    @StateObject var model = ViewModel()
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
            HomeView()
                  .environmentObject(model)
                  .environmentObject(login)
        }else{
            Text("Page not found")
        }
     
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
