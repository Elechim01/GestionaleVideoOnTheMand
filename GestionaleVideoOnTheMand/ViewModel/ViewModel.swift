//
//  ViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
import FirebaseStorage


class ViewModel: ObservableObject, HomeProtocol{
    
    @Published var fileName = ""
    var file : URL = URL(fileURLWithPath: "")
    internal var listOfUrl : [URL] = []
    internal var files : [URL: String] =  [:]
    internal var filesDimensionMB: [URL: Double] = [:]
    @Published var urlFileUplodato : String = ""
    @Published var urlThumbnail: URL = URL(fileURLWithPath: "")
    @Published var progress: Double = 0
    @Published var films : [Film] = []
    @Published var localUser : Utente = Utente()
    @Published var urlFileLocale: String = ""
    @Published var taskUploadImage: StorageUploadTask?
    @Published var stato: String = ""
//    @Published var elencoFilm : [String] = []
//    Memorizzo la password, l'email e l'id 
    @AppStorage("Password") internal var password = ""
    @AppStorage("Email") internal var email = ""
    @AppStorage("IDUser") internal var idUser = ""
    
   @Published var thumbnail : NSImage?
    var  indexListOfUrl = 0
    
//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
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
        stato = "creo la migniatura dell'immagine"
        thumbnail =  Extensions.createThumbnail(url: file)
       if(thumbnail == nil){
           self.alertMessage = "Impossibile creare migniatura"
           self.showAlert = true
           return
       }
       stato = "Carico il film"
//        MARK: Carico il film
        if(Extensions.isConnectedToInternet()){
            self.uploadFilm {
                self.uploadThumbnail(thumbnail: self.thumbnail!, succes: { [weak self] film in
                    guard let self = self else { return }
                    self.addFilm(film: film)
                })
            }
        }else{
            alertMessage = CustomError.connectionError.description
            showAlert = true
        }
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
    
    func uploadThumbnail(thumbnail: NSImage,succes:@escaping (Film)->Void ) {
        let data : Data = thumbnail.tiffRepresentation!
        let pathThumbnailFile =  Extensions.getThumbnailName(nameOfElement:fileName)
        let referenceRef = firebaseStorage.reference(withPath: "\(localUser.id)/\(pathThumbnailFile)")
        taskUploadImage = referenceRef.putData(data,metadata: nil){ [weak self] metadata,error in
            guard let self = self else { return }
            guard metadata != nil else{
                self.alertMessage = error!.localizedDescription
                self.showAlert.toggle()
                return
            }
        }
        
        taskUploadImage!.observe(.progress, handler: { [weak self]  snapshot in
            guard let self = self else { return }
            self.progress = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        })
        
        taskUploadImage!.observe(.failure) { [weak self] snapshot in
            guard let self = self else { return }
            if let error = snapshot.error as? NSError{
                switch (StorageErrorCode(rawValue: error.code)!){
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have perimission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    self.stato = "Cancellato"
                    self.fileName = ""
                    self.urlFileUplodato = ""
                    self.urlThumbnail = URL(fileURLWithPath: "")
                    self.progress = 0
                    return
                case .unknown:
                    print("Unknown error occured,inspect the server respose")
                    break
                default:
                    print("A separate error occurred. This is a good place to retry the upload.")
                    break
                }
            }
        }
        
        taskUploadImage!.observe(.success, handler: { [weak self] _ in
            guard let self = self else { return }
            referenceRef.downloadURL { url, error in
                guard let downloadUrl = url else{
                    self.alertMessage = error!.localizedDescription
                    self.showAlert.toggle()
                    return
                }
                self.urlThumbnail = downloadUrl
                //                self.taskUploadImage!.removeAllObservers()
                self.stato = "Aggiungo il film a db"
    //        MARK: Aggiungo il film a db
                succes(
                    Film(id: "",
                         idUtente: self.localUser.id,
                         nome: self.fileName,
                         url: self.urlFileUplodato,
                         thmbnail: self.urlThumbnail.absoluteString,
                         size: self.filesDimensionMB[self.file] ?? 0)
                )
            }
        })
        
    }
    
    func uploadFilm(success:@escaping () ->Void) {
        let fileRef = firebaseStorage.reference().child("\(localUser.id)/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        taskUploadImage = fileRef.putFile(from: file,metadata: metadata)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            print(self.progress)
             if self.progress < 7 {
                 self.taskUploadImage?.pause()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.taskUploadImage?.resume()
                }
            }
        }
        //        Upload File
        
        taskUploadImage!.observe(.progress) { [weak self] snapshot  in
            guard let self = self else { return }
            self.progress = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
        
        taskUploadImage!.observe(.failure) { [weak self] snapshot in
            guard let self = self else { return }
            if let error = snapshot.error as? NSError{
                switch (StorageErrorCode(rawValue: error.code)!){
                case .objectNotFound:
                    print("File doesn't exist")
                    break
                case .unauthorized:
                    print("User doesn't have perimission to access file")
                    break
                case .cancelled:
                    print("User canceled the upload")
                    self.stato = "Cancellato"
                    self.fileName = ""
                    self.urlFileUplodato = ""
                    self.urlThumbnail = URL(fileURLWithPath: "")
                    self.progress = 0
                    return
                case .unknown:
                    print("Unknown error occured,inspect the server respose")
                    break
                default:
                    print("A separate error occurred. This is a good place to retry the upload.")
                    break
                }
            }
        }
       
        taskUploadImage!.observe(.success) { [ weak self] snapshot in
            guard let self = self else { return }
            fileRef.downloadURL { [weak self] url, err in
                guard let self = self, let downloadUrl = url else{
                    print(err!.localizedDescription)
                    return
                }
                self.urlFileUplodato = downloadUrl.absoluteString
                self.stato = "Carico la thumbnail"
        //        MARK: Carico la thumbnail
                success()
            }
        }
        
        
    }
   
    func downloadFile(nomeFile:String, success:@escaping () -> Void, failure: @escaping (Error)->Void){
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
    
    public func deleteFile(nomeFile: String){
       
        deleteFile(firebaseStorage: firebaseStorage,localUser: localUser.id ,nomeFile: nomeFile) {
            print("Success")
        } failure: { error in
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
// MARK: Firestore
    
    internal func recuperoFilms(ending: (()->())?) {
       recuperoFilms(firestore: firestore, localUser: localUser.id) { [weak self] documents in
            guard let self = self else { return }
            films.removeAll()
            for document in documents{
                let id = document.documentID
                let data = document.data()
                if var film = Film.getFilm(json: data) {
                    film.id = id
                    self.films.append(film)
                    updateFilm(firestore: firestore, film: film) { error in
                        if let err = error {
                            self.alertMessage = err.localizedDescription
                            self.showAlert.toggle()
                        }
                    }
                    print(self.films)
                    self.films =  self.films.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedAscending })
                    ending?()
                } else {
                    self.alertMessage = CustomError.fileError.description
                    self.showAlert.toggle()
                }
            }
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
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
                        self.localUser.id = id
                        updateUser(firestore: firestore, user: self.localUser) { error in
                            if let err = error {
                                self.alertMessage = err.localizedDescription
                                self.showAlert.toggle()
                            }
                        }
                        ending?()
                    } else {
                        self.alertMessage = CustomError.fileError.description
                        self.showAlert.toggle()
                    }
                }
                print(self.localUser)
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
                self.stato = "Completato con successo"
                
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
                    self.thumbnailAndUploadFile()
                    
                }else
                {
                    self.listOfUrl = []
                    self.files = [:]
                    self.urlFileUplodato = ""
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
    
}
