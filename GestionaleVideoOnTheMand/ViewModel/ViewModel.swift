//
//  ViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
import FirebaseStorage
import LocalAuthentication


class ViewModel: ObservableObject, HomeProtocol {
    let api = ApiManager()
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
    @Published var taskUploadImage: StorageUploadTask?
    @Published var stato: UploadStatus? 
//    @Published var elencoFilm : [String] = []
//    Memorizzo la password, l'email e l'id 
    @AppStorage("IDUser") internal var idUser = ""
    var email: String = ""
    var password: String = ""
   @Published var thumbnail : NSImage?
    var  indexListOfUrl = 0
    
//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    var localFileName: String = ""
    var localThumbnailName: String = ""
    
    public var totalSizeFilm: Double {
        var size = 0.0
        films.forEach { size += $0.size }
        return size 
    }
    
    public let totalSize = 5000.0
    
    private let firestore : Firestore
    private let firebaseStorage: Storage
    
    init(){
        firestore = Firestore.firestore()
        firebaseStorage = Storage.storage()
       
        #warning("Remove this and load with keychain")
        email = "morotto91@outlook.it"
        password = "Michele1"
        
        #if DEV
        email = "morotto91@outlook.it"
        password = "Michele1"
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
    
    func thumbnailAndUploadFile(){
        stato = .createThumnail
        thumbnail =  Extensions.createThumbnail(url: file)
       if(thumbnail == nil){
           self.alertMessage = "Impossibile creare migniatura"
           self.showAlert = true
           return
       }
        stato = .uploadFilm
//        MARK: Carico il film
        
        if(Extensions.isConnectedToInternet()){
            // Upload Film
            Task {
                
                for await  update in  UploadFilmRequest(file: file).uploadFilmAsync() {
                    if let progress = update.progress {
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.progress = progress * 100
                        }
                    }
                    if let response = update.response {
                        await MainActor.run {[weak self] in
                            guard let self = self else { return }
                            self.urlFileUplodato = response.completeURL
                            localFileName = response.fileName
                            self.stato = .uploadThumbnail
                            
                        }
                    }
                    if let error = update.error {
                        await MainActor.run { [weak self] in 
                            guard let self = self else { return }
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                    }
                }
                
                guard let thumbnail = self.thumbnail else { return }
                let fileURLThumbnail = createTempFile(from: thumbnail)
                
                for await thumbnailupdate in UploadFilmRequest(file: fileURLThumbnail).uploadFilmAsync() {
                    if let progress = thumbnailupdate.progress {
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.progress = progress * 100
                        }
                    }
                    if let response = thumbnailupdate.response {
                        await MainActor.run {[weak self] in
                            guard let self = self else { return }
                            if let responseURl = URL(string: response.completeURL) {
                                self.urlThumbnail = responseURl
                            }
                            localThumbnailName = response.fileName
                            self.stato = .addFilmToDB
                            
                        }
                    }
                    if let error = thumbnailupdate.error {
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.alertMessage = error.localizedDescription
                            self.showAlert = true
                        }
                    }
                    
                }
                
                guard let localUser = self.localUser else { return }
            
                let film = Film(id: UUID().uuidString,
                        idUtente: localUser.id,
                        nome: self.fileName,
                        url: self.urlFileUplodato,
                        thmbnail: self.urlThumbnail.absoluteString,
                        size: self.filesDimensionMB[self.file] ?? 0,
                        fileName: localFileName,
                        thumbnailName: localThumbnailName
                    )
                
                self.addFilm(film: film)
                
            }

        }else{
            alertMessage = CustomError.connectionError.description
            showAlert = true
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
                } catch let error as CustomError {
                    self.alertMessage = error.description
                    self.showAlert.toggle()
                } catch  {
                    self.alertMessage = error.localizedDescription
                    self.showAlert.toggle()
                }
            }
        }
    }
    
// MARK: Firebase Storage
    
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
    
    public func deleteFile(fileName: String) async {
        do {
          let result = try await DeleteRequest(fileName: fileName).performAsync()
          print(result.message)
        } catch {
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
        /*
        guard let localUser = self.localUser else { return }
        deleteFile(firebaseStorage: firebaseStorage,localUser: localUser.id ,nomeFile: nomeFile) {
            print("Success")
        } failure: { error in
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
         */
    }
    
// MARK: Firestore
    
     func recuperoFilms(ending: (()->())?) {
        guard let localUser = self.localUser else {
        ending?()
            return
        }
       recuperoFilms(firestore: firestore, localUser: localUser.id) { [weak self] documents in
            guard let self = self else { return }
            films.removeAll()
            for document in documents{
                let id = document.documentID
                let data = document.data()
                if var film = Film.getFilm(json: data) {
                    film.id = id
                    self.films.append(film)
                    
                } else {
                    self.alertMessage = CustomError.fileError.description
                    self.showAlert.toggle()
                }
            }
           self.films.forEach { print("\($0.nome)") }
           self.films =  self.films.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedAscending })
           ending?()
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
            ending?()
        }
    }
    
    func recuperoUtente(email: String, password:String,id: String,ending: (()->())?){
        
      recuperoUtente(firestore: firestore, email: email, password: password){ [weak self] querySnapshot, err  in
            guard let self = self else { return }
            if let err = err {
                self.alertMessage = err.localizedDescription
                self.showAlert.toggle()
               ending?()
                
            }else{
                
                if(querySnapshot!.documents.count > 1){
                    self.alertMessage = "Errore nel DB presente più utenti"
                    self.showAlert.toggle()
                    ending?()
                }else{
                    if(querySnapshot!.documents.first == nil){
                        return
                    }
                    let data = querySnapshot!.documents.first!.data()
                    
                    if let user = Utente.getUser(json: data) {
                        self.localUser = user
                        self.localUser?.id = id
                        /*
                        updateUser(firestore: firestore, user: self.localUser!) { error in
                            if let err = error {
                                self.alertMessage = err.localizedDescription
                                self.showAlert.toggle()
                            }
                        }
                         */
                        ending?()
                    } else {
                        self.alertMessage = CustomError.fileError.description
                        self.showAlert.toggle()
                    }
                }
            }
        }
    }
    
    func addFilm(film:Film) {
     addFilm(firestore: firestore, film: film) { [ weak self] err in
            guard let self = self else { return }
            if err != nil{
                self.alertMessage = err!.localizedDescription
                self.showAlert = true
            }else{
                print("Success")
                self.stato = .succes
                
        //        MARK: Resetto le variabili
                self.fileName = ""
                self.urlFileUplodato = ""
                self.urlThumbnail = URL(fileURLWithPath: "")
                self.progress = 0.0
                
//                MARK: Multiple selection
                if(self.indexListOfUrl != self.listOfUrl.count-1){
//                    Accedo con l'index
                    self.indexListOfUrl += 1
                    self.file = self.listOfUrl[self.indexListOfUrl]
                    self.fileName = self.files[self.listOfUrl[self.indexListOfUrl]]!
                    DispatchQueue.main.async {
                        self.thumbnailAndUploadFile()
                    }
                    
                } else {
                    self.listOfUrl = []
                    self.files = [:]
                    self.urlFileUplodato = ""
                    self.thumbnail = nil
                    self.stato = nil
                }
            }
        }
    }
       
    func addUtente(utente:Utente){
        self.addUtente(firestore: firestore, utente: utente) {
            print("Succes!!!")
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }

    func removeDocument(film:Film){
        self.removeDocument(firestore: firestore, film: film) {
            print("Success")
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
    func authenticate(response: @escaping (Bool) -> ()) {
        let contex = LAContext()
        var error: NSError?
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, error: &error) {
            let reason = "Dacci i tuoi dati stronzo!:)"
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometricsOrWatch, localizedReason: reason) { [ weak self] value, error in
                guard let self = self else { return }
                if let error = error {
                    self.alertMessage = error.localizedDescription
                    self.showAlert.toggle()
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
