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
    
    // Il Coordinator è l'unico StateObject.
    // Gestisce lui la creazione di tutti i HomeViewModel tramite il Container.
    @StateObject private var coordinator = Coordinator()
    
    var body: some Scene {
        // --- FINESTRA PRINCIPALE ---
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
                .environmentObject(coordinator) // Passiamo il coordinatore a cascata
                .onAppear {
                    Task {
                        // Ripristina la sessione all'avvio: decide lui se andare in Login o Home
                        await coordinator.restoreSession()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            appCommands
        }
        
        // --- FINESTRA UPLOAD ---
        Window("UploadFilm", id: "uploadFilm") {
            UploadFilmView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Blue").opacity(0.3).ignoresSafeArea())
                .environmentObject(coordinator) // Passiamo il coordinator per coerenza
                .environmentObject(coordinator.homeViewModel)
                .environmentObject(coordinator.loadFilmHomeViewModel)
                .alwaysOnTop()
        }
        .windowStyle(.hiddenTitleBar)
        
        // --- FINESTRA INFO UTENTE ---
        Window("InfoUser", id: "infoUser") {
            InfoUserView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("Green").opacity(0.3).ignoresSafeArea())
                .environmentObject(coordinator)
                .environmentObject(coordinator.homeViewModel)
                .alwaysOnTop()
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    // MARK: - Menu Commands
    @CommandsBuilder
    private var appCommands: some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Impostazioni") {
                print("Apertura impostazioni...")
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        
        CommandGroup(replacing: .help) {
            Button("Logout") {
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
