//
//  Coordinator.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/03/26.
//

import Foundation
import SwiftUI

@MainActor
class Coordinator: ObservableObject {
    // Salviamo direttamente il tipo Page
    @AppStorage("CurrentPage") var currentPage: Page = .Login
    
    private static let container = DependencyContainer()
    
    @Published var homeViewModel: HomeViewModel
    @Published var loginHomeViewModel: LoginHomeViewModel
    @Published var loadFilmHomeViewModel: LoadFilmHomeViewModel
    @Published var registrationHomeViewModel: RegistrationHomeViewModel
    @Published var chronologyViewModel: ChronologyViewModel
    
    
    init() {
        self.homeViewModel = Self.container.makeHomeViewModel()
        self.loadFilmHomeViewModel = Self.container.makeLoadHomeViewModel()
        self.loginHomeViewModel = Self.container.makeLoginHomeViewModel()
        self.registrationHomeViewModel = Self.container.makeRegistrationHomeViewModel()
        self.chronologyViewModel = Self.container.makeChronologyHomeViewModel()
    }
    
    // --- LOGICA DI NAVIGAZIONE ---
    
    func restoreSession() async {
        let isSessionRestored = await loginHomeViewModel.restoreSession()
        if isSessionRestored {
            await startHome()
        } else {
            currentPage = .Login
        }
    }
    
    func login() async {
        let success = await loginHomeViewModel.login()
        if success {
            await startHome()
        }
    }
    
    func registration() async {
        let success = await registrationHomeViewModel.registration()
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
        if loginHomeViewModel.logOut() {
            homeViewModel.clearData()
            currentPage = .Login
        }
    }
}
