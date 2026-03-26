//
//  GestionaleVideoOnTheMandApp.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import AppKit
import Cocoa
import Firebase

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupFirebase()
    }
    
    func setupFirebase() {
        FirebaseApp.configure()
        Firestore.firestore()
    }
}


@main
struct GestionaleVideoOnTheMandApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private static let container = DependencyContainer()
    
    @StateObject var model: ViewModel
    @StateObject var loginViewModel: LoginViewModel
    @StateObject var loadFilmViewModel: LoadFilmViewModel
    
    
    init() {
        _model = StateObject(wrappedValue: Self.container.makeViewModel())
        _loadFilmViewModel = StateObject(wrappedValue: Self.container.makeLoadViewModel())
        _loginViewModel = StateObject(wrappedValue: Self.container.makeLoginViewModel())
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(
                    minWidth: 720,
                    idealWidth: 1100,
                    maxWidth: .infinity,
                    minHeight: 520,
                    idealHeight: 760,
                    maxHeight: .infinity
                )
                .environmentObject(model)
                .environmentObject(loginViewModel)
                .onAppear {
                    Task {
                        await loginViewModel.restoreSession()
                    }
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Impostazioni") {
                    print("Impostazioni")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        Window("UploadfFilm", id: "uploadFilm") {
            UploadFilmView()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background(Color("Blue").opacity(0.3).ignoresSafeArea())
                .environmentObject(model)
                .environmentObject(loadFilmViewModel)
                .alwaysOnTop()
            
            // Quando carico i film
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("InfoUser", id:"infoUser") {
            InfoUserView()
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background(Color("Green").opacity(0.3).ignoresSafeArea())
                .alwaysOnTop()
                .environmentObject(model)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}




extension NSTextField{
    open override var focusRingType: NSFocusRingType{
        get { .none }
        set { }
    }
}
