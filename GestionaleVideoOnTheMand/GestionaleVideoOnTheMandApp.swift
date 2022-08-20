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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension NSTextField{
    open override var focusRingType: NSFocusRingType{
        get{.none}
        set{}
    }
}
