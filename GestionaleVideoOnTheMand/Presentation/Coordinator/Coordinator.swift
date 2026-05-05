//
//  Coordinator.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/03/26.
//

import Foundation
import SwiftUI
import ElechimCore

@MainActor
class Coordinator: ObservableObject {
    // Salviamo direttamente il tipo Page
    @AppStorage("CurrentPage") var currentPage: Page = .Login
    //  var dismissWindowAction: DismissWindowAction?
    
    static let container = DependencyContainer()
    
    @Published var homeViewModel: HomeViewModel
    @Published var loginViewModel: LoginViewModel
    @Published var loadFilmViewModel: LoadFilmViewModel
    @Published var registrationViewModel: RegistrationViewModel
    @Published var chronologyViewModel: ChronologyViewModel
    
    
    init() {
        self.homeViewModel = Self.container.makeHomeViewModel()
        self.loadFilmViewModel = Self.container.makeLoadHomeViewModel()
        self.loginViewModel = Self.container.makeLoginHomeViewModel()
        self.registrationViewModel = Self.container.makeRegistrationHomeViewModel()
        self.chronologyViewModel = Self.container.makeChronologyHomeViewModel()
    }
    
    // --- LOGICA DI NAVIGAZIONE ---
    
    func restoreSession() async {
        let isSessionRestored = await loginViewModel.restoreSession()
        if isSessionRestored {
            await startHome()
        } else {
            currentPage = .Login
        }
    }
    
    func login() async {
        let success = await loginViewModel.login()
        if success {
            await startHome()
        }
    }
    
    func registration() async {
        let success = await registrationViewModel.registration()
        if success {
            await startHome()
        }
    }
    
    func goToRegistration() {
        currentPage = .Registration
    }
    
    func goToLogin() {
        currentPage = .Login
    }
    
    func startHome() async {
        await homeViewModel.start()
        currentPage = .Home
        
    }
    
    func logout() {
        CustomLog.debug(category: .VM, "Inizio procedura logout...")
        
        // 1. Eseguiamo il logout del ViewModel
        let hasLoggedOut = loginViewModel.logOut()
        
        // Se non stampa i log qui, il problema è DENTRO loginHomeViewModel.logOut()
        if hasLoggedOut {
            CustomLog.debug(category: .VM, "Logout eseguito con successo, pulizia dati...")
            
            homeViewModel.clearData()
            
            // Infine cambiamo pagina
            currentPage = .Login
        } else {
            CustomLog.error(category: .VM, "Il loginHomeViewModel.logOut() ha restituito false!")
        }
    }
}
