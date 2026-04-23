//
//  NewHome.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 27/07/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    @ObservedObject var homeViewModel: HomeViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @Environment(\.openWindow) var openWindow
    @State private var homeSection: HomeSection = .film
    @State private var showLogoutConfirm: Bool = false
    
    init(coordinator: Coordinator) {
        homeViewModel = coordinator.homeViewModel
       
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // --- SIDEBAR ---
            VStack(alignment: .leading) {
                // Info Utente (Dati presi dal HomeViewModel nel Coordinator)
                InfoUser(name: coordinator.homeViewModel.sessionManager.currentUser?.nome ?? "Utente")
                
                ListButton(text: "video.count".localized(), imageName: "film", section: .film)
                ListButton(text: "server.space".localized(), imageName: "opticaldiscdrive", section: .spazio)
                ListButton(text: "chronologia", imageName: "clock.arrow.trianglehead.counterclockwise.rotate.90", section: .chronology)
                
                Spacer()
            }
            .padding(.horizontal, 5)
            
        } detail: {
            // --- DETAIL VIEW ---
            ZStack {
                switch homeSection {
                case .film:
                    FilmView()
                        .environmentObject(coordinator.homeViewModel)
                case .spazio:
                    StorageView()
                        .environmentObject(coordinator.homeViewModel)
                case .chronology:
                    ChronologyView()
                        .environmentObject(coordinator.chronologyViewModel)
                }
                
                if coordinator.homeViewModel.isLoading {
                    //Aggiornamento dati...
                    ProgressView("server.progress.upload.data")
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 600, maxWidth: .infinity, minHeight: 400, idealHeight: 700, maxHeight: .infinity)
        .containerBackground(.ultraThinMaterial, for: .window)
        .navigationSplitViewStyle(.balanced)
        // Gestione schede dettaglio film
        .sheet(item: $homeViewModel.selectedFilmForInfo) { film in
            FilmInfoSheet(film: film)
                .environmentObject(coordinator.homeViewModel)
        }
        // Alert per errori dal HomeViewModel della Home
        .alert(homeViewModel.alertMessage, isPresented: $homeViewModel.showAlert) {
            Button("system.alert.ok", role: .cancel) {
               homeViewModel.showAlert = false
            }
        }
        // Alert di conferma Logout
        .alert("system.logout", isPresented: $showLogoutConfirm) {
            Button("system.cancel", role: .cancel) { }
            Button("system.confirm", role: .destructive) {
                coordinator.logout()
            }
        } message: {
            Text("system.request.logout")
        }
    }
    
    // MARK: - Componenti Helper (ViewBuilders)
    
    @ViewBuilder
    func ListButton(text: String, imageName: String, section: HomeSection) -> some View {
        CustomButton(
            isActive: homeSection == section,
            trueColor: .blue,
            falseColor: .clear,
            action: { homeSection = section }
        ) {
            HStack(spacing: 10) {
                Image(systemName: imageName)
                    .frame(width: 20)
                Text(text)
                Spacer()
            }
            .padding(.leading, 5)
        }
    }
    
    @ViewBuilder
    func InfoUser(name: String) -> some View {
        VStack(spacing: 5) {
            SimpleButton(color: .green.opacity(0.2)) {
                openWindow(id: "infoUser")
            } label: {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .padding(.leading,15)
                    Text(name)
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.primary)
            }
            
            SimpleButton(color: .red.opacity(0.1)) {
                showLogoutConfirm.toggle()
            } label: {
                HStack {
                    Image(systemName: "power")
                        .padding(.leading, 15)
                    Text("system.logout")
                    Spacer()
                }
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 10)
        
        Divider()
            .padding(.bottom, 10)
    }
}

struct NewHome_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(coordinator: Coordinator())
            .frame(width: 900, height: 600)
            .environmentObject(Coordinator())
    }
}


