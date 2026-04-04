//
//  ContentView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        Group {
            switch coordinator.currentPage {
            case .Login:
                LoginView(coordinator: coordinator)
            case .Registration:
                RegistrationView(coordinator: coordinator)
            case .Home:
                HomeView(coordinator: coordinator)
            }
        }
        .environmentObject(coordinator)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {       
        ContentView()
            .environmentObject(Coordinator())
    }
}
