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



import SwiftUI
import FirebaseCore
import FirebaseFirestore

// 1. Definisci un AppDelegate standard per macOS
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configura qui. È il posto più sicuro in assoluto su macOS.
        setupFirebase()
    }
    
    func setupFirebase() {
        FirebaseApp.configure()
    }
}


@main
struct GestionaleVideoOnTheMandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var model = ViewModel()
    @StateObject var loginModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(loginModel)
                .onAppear {
                    Task {
                       await  loginModel.restoreSession()
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
                .environmentObject(model)
                .alwaysOnTop()
            // Quando carico i film
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("InfoUser", id:"infoUser") {
            InfoUserView()
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
