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

@main
struct GestionaleVideoOnTheMandApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    @StateObject var model = ViewModel()
    @StateObject var loginModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(loginModel)
                .onAppear {
                    // Load Session
                    Task {
                       await  loginModel.restoreSession()
                    }
                    
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("UploadfFilm", id: "uploadFilm") {
            UploadFilmView()
                .environmentObject(model)
                .bringToFront()
            // Quando carico i film
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("InfoUser", id:"infoUser") {
            InfoUserView()
                .bringToFront()
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
