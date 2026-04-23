//
//  LoadFilmHomeViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 17/01/26.
//

import SwiftUI
import Services
import ElechimCore

@MainActor
class LoadFilmHomeViewModel: ObservableObject {
    
    // Proprietà che la View osserva
    @Published private(set) var steps: [Steps] = []
    @Published private(set) var progress: Double = 0
    @Published var stato: UploadStatus = .loadFilm
    @Published private(set) var thumbnail: NSImage?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var fileName: String = ""
    
    // Stato interno (Privato)
    private var uploadQueue: [UploadItem] = []
    
    private let uploadMovieUseCase: UploadMovieUseCase
    private let sessionManager: SessionManager
    
    init(uploadMovieUseCase: UploadMovieUseCase,
         sessionManager: SessionManager) {
        self.uploadMovieUseCase = uploadMovieUseCase
        self.sessionManager = sessionManager
        generateSteps()
    }
    
    func startUploadProcess(){

        // Cuore Pulsante uso un dizionario chiave tupla così passo gli elementi all'esterno 
        let selection =  FileHelper.selectMovies()
        
        guard !selection.isEmpty else { return }
        
       
        self.uploadQueue = selection
        
        processNextUpload()
    }
    
    
    private func processNextUpload() {
        guard !uploadQueue.isEmpty else {
            resetEntireQueue()
            return
        }
        
        // invece che controllare gli array con gli indici
        // scalo l'elemento dall'array
        let metadata = uploadQueue.removeFirst()
        
        guard let user = sessionManager.currentUser else { return }
        self.resetCurrentUploadUI()
        self.fileName = metadata.name
        Task {
            do {
                
                try await uploadMovieUseCase.execute(idLocalUser: user.id,
                                                     nome: metadata.name,
                                                     file: metadata.url,
                                                     size: metadata.size,
                                                     onCreateThumbnail: { [weak self] image in
                    
                    guard let self = self else {return }
                    self.thumbnail = image
                    
                }, onUpdate: { [weak self] key, progress in
                    guard let self = self else { return }
                    self.updateStep(key: key, progress: progress)
                    
                })
                self.stato = .end
                self.processNextUpload()
            } catch  {
                self.showError(from: error)
                self.resetEntireQueue()
            }
        }
    }
    
    private func updateStep(key: UploadStatus, progress: Double = 0) {
        //createThumnail
        //uploadFilm
        //uploadThumbnail
        //addFilmToDB
        //succes
        
        guard let index: Int = self.steps.firstIndex(where:  { step in
            step.type == key
        }) else { return }
        self.stato = key
        self.progress = progress
        self.steps[index].progress = progress
    }
    
    private func resetEntireQueue() {
        self.uploadQueue = []
        self.stato = .end
    }
    
    private func resetCurrentUploadUI() {
        self.thumbnail = nil
        self.progress = 0
        generateSteps()
    }
    
    private func generateSteps() {
        steps = UploadStatus.steps.map { status in
            Steps(type: status)
        }
    }
    
    private func showError(from error: Error) {
        CustomLog.error(category: .VM, "\(error.localizedDescription)")
        Utils.showError(alertMessage: &alertMessage, showAlert: &showAlert, from: error)
    }
    
}
