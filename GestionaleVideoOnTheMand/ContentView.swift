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
        if(login.page == 0){
            LoginView()
                .environmentObject(login)
                .environmentObject(model)
        }else if(login.page == 1){
            RegistrationView()
                .environmentObject(login)
                .environmentObject(model)
        }else if(login.page == 2){
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
