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
    
    @StateObject var model = ViewModel()
    @StateObject var loginModel = LoginViewModel()
    
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
                .environmentObject(loginModel)
                .onAppear {
                    Task {
                        await loginModel.restoreSession()
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
