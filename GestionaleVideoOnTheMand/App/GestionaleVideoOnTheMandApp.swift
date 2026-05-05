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
import UserNotifications
import ElechimCore

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
    @StateObject private var coordinator = Coordinator()
    var body: some Scene {
        // --- FINESTRA PRINCIPALE ---
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, idealWidth: 1100, maxWidth: .infinity, minHeight: 520, idealHeight: 760, maxHeight: .infinity)
                .environmentObject(coordinator)
                .onAppear {
                    Task {
                        await coordinator.restoreSession()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands { appCommands }
        
        // --- FINESTRA UPLOAD ---
        Window("window.upload.film", id: "uploadFilm") {
            UploadFilmView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Blue").opacity(0.3).ignoresSafeArea())
                .environmentObject(coordinator.loadFilmViewModel)
                .alwaysOnTop()
        }
        .windowStyle(.hiddenTitleBar)
        
        // --- FINESTRA INFO UTENTE ---
        Window("window.info.user", id: "infoUser") {
            InfoUserView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Green").opacity(0.3).ignoresSafeArea())
                .environmentObject(Coordinator.container.sessionManager)
               .alwaysOnTop()
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    // MARK: - Menu Commands
    @CommandsBuilder
    private var appCommands: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("system.button.logout") {
                coordinator.logout()
            }
        }
    }
}


extension NSTextField{
    open override var focusRingType: NSFocusRingType{
        get { .none }
        set { }
    }
}
