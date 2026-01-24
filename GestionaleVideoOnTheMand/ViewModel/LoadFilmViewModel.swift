//
//  LoadFilmViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 17/01/26.
//

import SwiftUI
import Services

@MainActor
class LoadFilmViewModel: ObservableObject {
    
    var file : URL = URL(fileURLWithPath: "")
    var listOfUrl : [URL] = []
    var files : [URL: String] =  [:]
    var filesDimensionMB: [URL: Double] = [:]
    @Published var fileName = ""
    @Published var urlFileUplodato : String = ""
    @Published var urlThumbnail: URL = URL(fileURLWithPath: "")
    
    
    @Published var steps: [Steps] = []
    @Published var progress: Double = 0
    @Published var stato: UploadStatus = .loadFilm
    @Published var thumbnail : NSImage?
    
    var indexListOfUrl = 0
    var localFileName: String = ""
    var localThumbnailName: String = ""
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading = false
    var localUser: Utente?
    
    
    
    init() {
       generateSteps()
    }
    
    
    private func generateSteps() {
        steps = UploadStatus.steps.map { status in
             Steps(type: status)
         }
    }
    
    func uploadFileToDb(localUser: Utente?){
//        se l'utente cancella l'upload faccio fermare tutto e svuto ogni cosa
//        MARK: seleziono il file
//        GenerateSteps
       
        self.localUser = localUser
        
        selectfile()
        
        if(files == [:]){
            return
        }
//      MARK: creo la migniatura dell'immagine
        
        for (url,_) in self.files {
            self.listOfUrl.append(url)
        }
        guard let firstFile = listOfUrl.first else { return }
        self.file = firstFile
        self.fileName = files[firstFile] ?? ""
        
        
        thumbnailAndUploadFile()
    }
    
    func thumbnailAndUploadFile() {
       
        
        if(Utils.isConnectedToInternet()){
            // Upload Film
            Task {
                do {
                    stato = .createThumnail
                    updateStep(key: .createThumnail)
                    thumbnail = await Utils.createThumbnail(url: file)
                    guard let thumbnail = self.thumbnail else {
                        throw CustomError.fileError
                    }
                    updateStep(key:  .createThumnail, progress: 100)
                    
                    stato = .uploadFilm
                    updateStep(key:  .uploadFilm)
                    //        MARK: Carico il film
                    
                    let filmsResponse = try await upload(file: file) {[weak self] progress in
                        guard let self = self else { return }
                     
                        self.progress = progress
                        updateStep(key:  .uploadFilm, progress: progress)
                    }
                    await MainActor.run {[weak self] in
                        guard let self = self else { return }
                        self.urlFileUplodato = filmsResponse.completeURL
                        localFileName = filmsResponse.fileName
                        self.stato = .uploadThumbnail
                        updateStep(key:  .uploadThumbnail)
                        withAnimation(.linear(duration: 0.2)) {
                            self.progress = 0
                        }
                    }
                    
                   
                    let fileURLThumbnail = createTempFile(from: thumbnail)
                    let thumbResponse = try await upload(file: fileURLThumbnail) {[weak self] progress in
                        guard let self = self else { return }
                        self.progress = progress
                        updateStep(key: .uploadThumbnail, progress: progress)
                    }
                    await MainActor.run {[weak self] in
                        guard let self = self else { return }
                        if let responseURl = URL(string: thumbResponse.completeURL) {
                            self.urlThumbnail = responseURl
                        }
                        localThumbnailName = thumbResponse.fileName
                        self.stato = .addFilmToDB
                        updateStep(key:  .addFilmToDB)
                        
                    }
                    
                    try await saveFilm()
                    
                    print("Success")
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        updateStep(key:  .addFilmToDB, progress: 100)
                        self.stato = .end
                        if files.count > 1 {
                            resetCurrentUpload()
                        }
                        multipleSection()
                       
                        
                    }
                } catch {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.resetCurrentUpload()
                        self.showError(from: error)
                    }
                   
                   
                }
            }
            
        }else{
            alertMessage = CustomError.connectionError.description
            showAlert = true
            resetCurrentUpload()
        }
    }
    


    private func saveFilm() async throws {
        guard let localUser = self.localUser else { throw CustomError.genericError }
    
        let film = Film(id: UUID().uuidString,
                idUtente: localUser.id,
                nome: self.fileName,
                url: self.urlFileUplodato,
                thmbnail: self.urlThumbnail.absoluteString,
                size: self.filesDimensionMB[self.file] ?? 0,
                fileName: localFileName,
                thumbnailName: localThumbnailName
            )
        
        try await FirebaseUtils.shared.addFilm(film: film)
    }
    
    private func upload(file: URL, onProgress: @escaping (Double) -> Void) async throws -> UploadFilmResponse {
        
        for await  update in  UploadFilmRequest(file: file).uploadFilmAsync() {
            if let progress = update.progress {
                await MainActor.run {
                    onProgress(progress)
                }
            }
            if let response = update.response {
                return response
            }
            if let error = update.error {
                throw error
            }
        }
        throw CustomError.genericError
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
        
        self.steps[index].progress = progress
    }
    
     func resetCurrentUpload() {
        self.fileName = ""
        self.urlFileUplodato = ""
        self.urlThumbnail = URL(fileURLWithPath: "")
        self.thumbnail = nil
        self.progress = 0.0
        generateSteps()
    }
    
    private func multipleSection() {
        self.indexListOfUrl += 1
        if(self.indexListOfUrl < self.listOfUrl.count){
            self.file = self.listOfUrl[self.indexListOfUrl]
            guard  let file =  self.files[self.listOfUrl[self.indexListOfUrl]] else  {
                self.listOfUrl = []
                self.files = [:]
                self.indexListOfUrl = 0
                return
            }
            self.fileName = file
            self.thumbnailAndUploadFile()
            
        } else {
            self.listOfUrl = []
            self.files = [:]
            self.indexListOfUrl = 0
        }
    }
    
    
    private func createTempFile(from image: NSImage) -> URL {
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("thumbnail.png")
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: tempUrl)
        }
        return tempUrl
    }
    
    func selectfile(){
        let pannell = NSOpenPanel()
        pannell.allowedContentTypes = [.movie]
        pannell.allowsMultipleSelection = true
        pannell.canChooseDirectories = false
        if pannell.runModal() == .OK {
            print(pannell.urls)
            for url in pannell.urls {
                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attr[FileAttributeKey.size] as? UInt64
                    if let fileSize {
                        let result = ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file).components(separatedBy: " ")
                        if  let dimensionsMB = Double(result[0].replacingOccurrences(of: ",", with: ".")) {
                            self.files.updateValue(url.lastPathComponent, forKey: url)
                            self.filesDimensionMB.updateValue(dimensionsMB, forKey: url)
                        } else {
                            throw CustomError.fileError
                        }
                    }
                } catch {
                    showError(from: error)
                }
            }
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
    
    
}


struct Steps {
    var type: UploadStatus
    var progress: Double
    var isComplete: Bool {
        progress == 100
    }
    
    init(type: UploadStatus) {
        self.type = type
        self.progress = 0.0
    }
    
}
