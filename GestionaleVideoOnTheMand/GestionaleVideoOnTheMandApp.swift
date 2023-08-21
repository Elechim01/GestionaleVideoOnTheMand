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
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("UploadfFilm", id: "uploadFilm") {
            UploadFilmView()
                .environmentObject(model)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Window("InfoUser", id:"infoUser") {
            InfoUserView()
                .environmentObject(model)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
    }
}

extension NSTextField{
    open override var focusRingType: NSFocusRingType{
        get{.none}
        set{}
    }
}
