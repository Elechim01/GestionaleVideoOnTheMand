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
    
    
    public var totalSizeFilm: Double {
        var size = 0.0
        films.forEach { size += $0.size }
        return size 
    }
    
    public let totalSize = 10000.0
    
    init(){
        #if DEV
        idUser = "zglR4HvR0sP3KEqaRGL8Ma5cx5t2"
        #endif
    }
    
// MARK: Firebase Storage
   /*
    func downloadFile(nomeFile:String, success:@escaping () -> Void, failure: @escaping (Error)->Void){
        guard let localUser = self.localUser else { return }
        let pathReference = firebaseStorage.reference(withPath: "\(localUser.id)/\(nomeFile)")
        let localPathReference = Utils.getDocumentsDirectory().appendingPathComponent(nomeFile)
        self.urlFileLocale = localPathReference.absoluteString
        let downloadTask = pathReference.write(toFile: localPathReference){ [weak self] url, error in
            guard let self = self else { return }
            if let error = error{
                failure(error)
                self.alertMessage = error.localizedDescription
                self.showAlert.toggle()
            }else{
                print(url?.absoluteString ?? "")
                success()
            }
        }
        
        downloadTask.observe(.progress) { [weak self] snapshot in
            guard let self = self else { return }
            self.progress = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
        
        downloadTask.observe(.failure) { [weak self] snapshot in
            guard let self = self else { return }
            if let error = snapshot.error as? NSError{
                failure(error)
                switch (StorageErrorCode(rawValue: error.code)!){
                case .objectNotFound:
                    self.alertMessage = "File doesn't exist"
                    break
                case .unauthorized:
                    self.alertMessage = "User doesn't have perimission to access file"
                    break
                case .cancelled:
                    self.alertMessage = "User canceled the upload"
                    break
                case .unknown:
                    self.alertMessage = "Unknown error occured,inspect the server respose"
                    break
                default:
                    self.alertMessage = "A separate error occurred. This is a good place to retry the upload."
                    break
                }
                self.showAlert.toggle()
            }
        }
    }
    */
    
    
    func deleteFile(film: Film) async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            
            guard let _ =  film.documentId  else {
                throw CustomError.genericError
            }
          let _ = try await DeleteRequest(fileName: film.fileName).performAsync()
          let _ = try await DeleteRequest(fileName: film.thumbnailName).performAsync()
            guard let _ = films.first(where: { filmRead in
                let value = filmRead.nome
                return value == film.nome
          }) else {
              throw CustomError.genericError
          }
            try await  FirebaseUtils.shared.removeDocument(filmId: film.documentId ?? "")
            
        } catch  {
            showError(from: error)
        }
    }
    
    
    func loadFilmView() async  {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            let credential = AuthKeyChain.shared.redCredential()
            guard let email = credential.email,
                  let password = credential.password else {
                // TODO: CHANGE ERROR TYPE
                throw CustomError.genericError
            }
            
            guard  let user: Utente = try await FirebaseUtils.shared.recuperoUtente(email: email, password: password, id: idUser) else {
                throw CustomError.genericError
            }
            self.localUser = user
            
            
            let stream: AsyncStream<[Film]> = await  FirebaseUtils.shared.recuperoFilm(localUserId: user.id)
            for await film in stream  {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
//                    TODO: CHANGE SORTED BY DATA
                    self.films = film.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedDescending })
                }
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

        
    
// MARK: Firestore

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
