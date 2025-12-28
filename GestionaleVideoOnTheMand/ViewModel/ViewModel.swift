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
    @Published var fileName = ""
    var file : URL = URL(fileURLWithPath: "")
    internal var listOfUrl : [URL] = []
    internal var files : [URL: String] =  [:]
    internal var filesDimensionMB: [URL: Double] = [:]
    @Published var urlFileUplodato : String = ""
    @Published var urlThumbnail: URL = URL(fileURLWithPath: "")
    @Published var progress: Double = 0
    @Published var films : [Film] = []
    @Published var localUser: Utente?
    @Published var urlFileLocale: String = ""
    @Published var stato: UploadStatus = .loadFilm
//    @Published var elencoFilm : [String] = []
//    Memorizzo la password, l'email e l'id 
    @AppStorage("IDUser") internal var idUser = ""
   @Published var thumbnail : NSImage?
    var  indexListOfUrl = 0
    
//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading = false
    
    var localFileName: String = ""
    var localThumbnailName: String = ""
    
    public var totalSizeFilm: Double {
        var size = 0.0
        films.forEach { size += $0.size }
        return size 
    }
    
    public let totalSize = 5000.0
    
    
    
    init(){
        #if DEV
        idUser = "zglR4HvR0sP3KEqaRGL8Ma5cx5t2"
        #endif
    }
    
    func uploadFileToDb(){
//        se l'utente cancella l'upload faccio fermare tutto e svuto ogni cosa
//        MARK: seleziono il file
        selectfile()
        
        if(files == [:]){
            return
        }
//      MARK: creo la migniatura dell'immagine
        
        for (url,_) in self.files {
            self.listOfUrl.append(url)
        }
        
        self.file = listOfUrl.first!
        self.fileName = files[listOfUrl.first!]!
        
        thumbnailAndUploadFile()
    }
    
    func thumbnailAndUploadFile() {
       
        
        if(Extensions.isConnectedToInternet()){
            // Upload Film
            Task {
                do {
                    stato = .createThumnail
                    thumbnail = await Extensions.createThumbnail(url: file)
                    if(thumbnail == nil){
                        self.alertMessage = "Impossibile creare migniatura"
                        self.showAlert = true
                        return
                    }
                    stato = .uploadFilm
                    //        MARK: Carico il film
                    
                    let filmsResponse = try await upload(file: file) {[weak self] progress in
                        guard let self = self else { return }
                        print(progress)
                        self.progress = progress
                    }
                    await MainActor.run {[weak self] in
                        guard let self = self else { return }
                        self.urlFileUplodato = filmsResponse.completeURL
                        localFileName = filmsResponse.fileName
                        self.stato = .uploadThumbnail
                        withAnimation(.linear(duration: 0.2)) {
                            self.progress = 0
                        }
                        
                        print(progress)
                        
                    }
                    
                    guard let thumbnail = self.thumbnail else { return }
                    let fileURLThumbnail = createTempFile(from: thumbnail)
                    let thumbResponse = try await upload(file: fileURLThumbnail) {[weak self] progress in
                        guard let self = self else { return }
                        self.progress = progress
                    }
                    await MainActor.run {[weak self] in
                        guard let self = self else { return }
                        if let responseURl = URL(string: thumbResponse.completeURL) {
                            self.urlThumbnail = responseURl
                        }
                        localThumbnailName = thumbResponse.fileName
                        self.stato = .addFilmToDB
                        
                    }
                    
                    try await saveFilm()
                    
                    self.stato = .succes
                    
                    print("Success")
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.stato = .succes
                        resetCurrentUpload()
                        multipleSection()
                        
                    }
                } catch {
                    showError(from: error)
                }
            }
            
        }else{
            alertMessage = CustomError.connectionError.description
            showAlert = true
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
    
    private func resetCurrentUpload() {
        self.fileName = ""
        self.urlFileUplodato = ""
        self.urlThumbnail = URL(fileURLWithPath: "")
        self.thumbnail = nil
        self.progress = 0.0
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
    
// MARK: Firebase Storage
   /*
    func downloadFile(nomeFile:String, success:@escaping () -> Void, failure: @escaping (Error)->Void){
        guard let localUser = self.localUser else { return }
        let pathReference = firebaseStorage.reference(withPath: "\(localUser.id)/\(nomeFile)")
        let localPathReference = Extensions.getDocumentsDirectory().appendingPathComponent(nomeFile)
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
            guard let filmToRemove = films.first(where: { filmRead in
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
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
            let reason = "Dacci i tuoi dati stronzo!:)"
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: reason) { [ weak self] value, error in
                guard let self = self else { return }
                if let error = error {
                    //self.alertMessage = error.localizedDescription
                   // self.showAlert.toggle()
                }
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
