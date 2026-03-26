//
//  ViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Services
import LocalAuthentication

@MainActor
class ViewModel: ObservableObject {
   
    @Published var films : [Film] = []
    @Published var localUser: Utente?
    @Published var urlFileLocale: String = ""
    @Published var selectedFilmForInfo: Film?
    @AppStorage("IDUser") internal var idUser = ""
 

//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading = false
    
    private let deleteUseCase: DeleteMovieUseCase
    private let fetchMovieUseCase: FetchMovieUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    
    
    
    public var totalSizeFilm: Double {
        var size = 0.0
        films.forEach { size += $0.size }
        return size 
    }
    
    public let totalSize = 10000.0
    
    init(deleteUseCase: DeleteMovieUseCase,
         fetchMovieUseCase: FetchMovieUseCase,
         getCurrentUserUseCase: GetCurrentUserUseCase
    ){
        self.deleteUseCase = deleteUseCase
        self.fetchMovieUseCase = fetchMovieUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        #if DEV
        idUser = "zglR4HvR0sP3KEqaRGL8Ma5cx5t2"
        #endif
    }
    
    func deleteFile(film: Film) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await deleteUseCase.execute(film: film)
        } catch  {
            showError(from: error)
        }
    }
    
    func start() async {
        await loadUser()
        await loadFilm()
    }
    
    private func loadUser() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let user = try await getCurrentUserUseCase.execute(idUser: self.idUser)
            self.localUser = user
        } catch  {
            showError(from: error)
        }
    }
    
    
    private func loadFilm() async  {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            guard let localUserId = localUser?.id else {
                //MARK: Error on Account
                throw CustomError.genericError
            }
            
            let stream = try await  fetchMovieUseCase.execute(localUserId: localUserId)
            for await film in stream  {
                // TODO: CHANGE SORTED BY DATA
                self.films = film.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedDescending })
            }
            
        } catch  {
            showError(from: error)
        }
    }
    
    
    private func showError(from error: Error) {
        if let custom = error as? CustomError {
            alertMessage = custom.description
        } else {
            alertMessage = error.localizedDescription
        }
        self.showAlert.toggle()
    }


//    TODO:  Apple
    func authenticate(response: @escaping (Bool) -> ()) {
        let contex = LAContext()
        var error: NSError?
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrCompanion, error: &error) {
            let reason = "Dacci i tuoi dati stronzo!:)"
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrCompanion, localizedReason: reason) { value, error in
               // guard let _ = self else { return }
               // if let error = error {
                    //self.alertMessage = error.localizedDescription
                   // self.showAlert.toggle()
               // }
                response(value)
//                if succes {
//                   succes?()
//                } else {
//                    print("NO Success")
//                }
            }
        } else {
            guard let error = error else { return }
            self.alertMessage =  error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
}
