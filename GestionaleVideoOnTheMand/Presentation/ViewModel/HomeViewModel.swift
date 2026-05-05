//
//  HomeViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Services
import LocalAuthentication
import ElechimCore

@MainActor
class HomeViewModel: ObservableObject {
   
    @Published var films : [Film] = []
    @Published var urlFileLocale: String = ""
    @Published var selectedFilmForInfo: Film?
 

//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading = false
    
    private let deleteUseCase: DeleteMovieUseCase
    private let fetchMovieUseCase: FetchMovieUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    let sessionManager: SessionManager
    private var fetchFilmsTask: Task<Void, Never>?
    
    
    public var totalSizeFilm: Double {
        var size = 0.0
        films.forEach { size += $0.size }
        return size 
    }
    
    public let totalSize = 10240.0
    
    init(deleteUseCase: DeleteMovieUseCase,
         fetchMovieUseCase: FetchMovieUseCase,
         getCurrentUserUseCase: GetCurrentUserUseCase,
         sessionManager: SessionManager
    ){
        self.deleteUseCase = deleteUseCase
        self.fetchMovieUseCase = fetchMovieUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.sessionManager = sessionManager
        #if DEV
        idUser = "zglR4HvR0sP3KEqaRGL8Ma5cx5t2"
        #endif
    }
    
    func deleteFile(film: Film) async {
        CustomLog.debug(category: .VM, "\(#function)")
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            try await deleteUseCase.execute(film: film)
        } catch  {
            showError(from: error)
        }
    }
    
    func start() async {
        CustomLog.debug(category: .VM, "\(#function)")
        await loadUser()
        fetchFilmsTask = Task {
            await loadFilm()
        }
    }
    
    func stopFetching() {
        CustomLog.debug(category: .VM, "Stopping Firestore stream...")
        fetchFilmsTask?.cancel()
        fetchFilmsTask = nil
    }
    
    private func loadUser() async {
        CustomLog.debug(category: .VM, "\(#function)")
        guard sessionManager.currentUser == nil else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let user = try await getCurrentUserUseCase.execute(idUser: self.sessionManager.idUser)
            self.sessionManager.currentUser = user
        } catch  {
            showError(from: error)
        }
    }
    
    
    private func loadFilm() async  {
        CustomLog.debug(category: .VM, "\(#function)")
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            guard let localUserId =  self.sessionManager.currentUser?.id else {
                //MARK: Error on Account
                throw CustomError.noUser
            }
            
            let stream = await  fetchMovieUseCase.execute(localUserId: localUserId)
            for try await film in stream  {
                if Task.isCancelled { break }
                // TODO: CHANGE SORTED BY DATA
                self.films = film.sorted(by:{ $0.nome.compare($1.nome,options: String.CompareOptions.caseInsensitive) == .orderedDescending })
                self.isLoading = false
            }
            
        } catch  {
            if !(error is CancellationError) {
                showError(from: error)
            } else {
                CustomLog.error(category: .VM, "Cancellazione errata. \(error.localizedDescription)")
            }
        }
    }
    
    
    private func showError(from error: Error) {
        CustomLog.error(category: .VM, "\(error.localizedDescription)")
        Utils.showError(alertMessage: &alertMessage, showAlert: &showAlert, from: error)
    }
    
    func clearData() {
        CustomLog.debug(category: .VM, "\(#function)")
        //0. ferma lo stream
        self.stopFetching()
        
        // 1. Resettiamo le liste e l'utente
        self.films = []
        sessionManager.currentUser = nil
        
        // 2. Puliamo eventuali selezioni o URL temporanei
        self.selectedFilmForInfo = nil
        self.urlFileLocale = ""
        
        // 3. Resettiamo lo stato della UI
        self.isLoading = false
        self.showAlert = false
        self.alertMessage = ""
        
        // NOTA: idUser essendo un AppStorage potrebbe essere resettato qui
        // o lasciato gestire al LoginHomeViewModel durante il logout.
        // Se vuoi pulirlo: self.idUser = ""
    }


//    TODO:  Apple
    func authenticate(response: @escaping (Bool) -> ()) {
        let contex = LAContext()
        var error: NSError?
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrCompanion, error: &error) {
            let reason = "Dacci i tuoi dati stronzo!:)"
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrCompanion, localizedReason: reason) { value, error in
                response(value)
            }
        } else {
            guard let error = error else { return }
            self.alertMessage =  error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
}
