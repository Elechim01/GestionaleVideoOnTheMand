//
//  ViewModel.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 11/08/22.
//

import SwiftUI
import Firebase
import FirebaseStorage


class ViewModel: ObservableObject{
    
    @Published var fileName = ""
    var file : URL = URL(fileURLWithPath: "")
    internal var listOfUrl : [URL] = []
    internal var files : [URL: String] =  [:]
    @Published var urlFileUplodato : String = ""
    @Published var urlThumbnail: URL = URL(fileURLWithPath: "")
    @Published var progress: Double = 0
    @Published var films : [Film] = []
    @Published var localUser : Utente = Utente()
    @Published var urlFileLocale: String = ""
    @Published var taskUploadImage: StorageUploadTask?
    @Published var stato: String = ""
    @Published var elencoFilm : [String] = []
//    Memorizzo la password, l'email e l'id 
    @AppStorage("Password") internal var password = ""
    @AppStorage("Email") internal var email = ""
    @AppStorage("IDUser") internal var idUser = ""
    
   @Published var thumbnail : NSImage?
    var  indexListOfUrl = 0
    
//    MARK: Alert
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    let firestore : Firestore
    let firebaseStorage: Storage
    
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
                    self.addFilm(film: film, success: {
                        self.getListFiles()
                    })
                })
            }
        }else{
            alertMessage = "Il dispositivo non è conneso a internet"
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
                self.files.updateValue(url.lastPathComponent, forKey: url)
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
                
                succes(Film(id: "", idUtente: self.localUser.id, nome: self.fileName, url: self.urlFileUplodato, thmbnail: self.urlThumbnail.absoluteString))
                
            
            }
           
        })
        
    }
    
    func uploadFilm(success:@escaping () ->Void) {
        let fileRef = firebaseStorage.reference().child("\(localUser.id)/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        taskUploadImage = fileRef.putFile(from: file,metadata: metadata)
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
        deleteFile(nomeFile: nomeFile) {
            print("Success")
        } failure: { error in
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
   private func deleteFile(nomeFile: String, success:@escaping ()->Void, failure: @escaping (Error) -> Void){
        let deleteRef = firebaseStorage.reference().child("\(localUser.id)/\(nomeFile)")
        deleteRef.delete { error in
            if let error = error{
                failure(error)
               
            }else{
                print("No Problem")
                success()
            }
        }
    }
    
    func getListFiles(){
        let storageRefernce = firebaseStorage.reference().child(localUser.id)
        storageRefernce.listAll { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                for prefisso in result!.prefixes{
                   print(prefisso.name)
                }
                self.elencoFilm = []
                for item in result!.items{
                    if(!item.name.contains("thumbnail")){
                        self.elencoFilm.append(item.name)
                        print(item.name)
                    }
                }
            }
        }
    }
    
// MARK: Firestore
    
    
   internal func recuperoFilms() {
        recuperoFilms { [weak self] documents in
            guard let self = self else { return }
            for document in documents{
                let id = document.documentID
                let data = document.data()
                let idUtente: String = data["idUtente"] as? String ?? ""
                let nomefile = data["nome"] as? String ?? ""
                let url :String = data["url"] as? String ?? ""
                let thumbanil : String = data["thumbnail"] as? String ?? ""

                self.films.append(Film(id: id, idUtente: idUtente, nome: nomefile, url: url, thmbnail: thumbanil))
            }
            print(self.films)
            self.films =  self.films.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedAscending })
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
    private func recuperoFilms(success:@escaping ([QueryDocumentSnapshot])->Void, failure:@escaping (Error) -> Void){
        print(localUser.id)
        firestore.collection("Film").whereField("idUtente", isEqualTo: localUser.id).addSnapshotListener { querySnapshot, error in
            if let erro = error{
                failure(erro)
            }
            else{
                self.films.removeAll()
                success(querySnapshot!.documents)
            }
        }
    }
    
    func recuperoUtente(email: String, password:String,id: String,ending: (()->())?){
        
        firestore.collection("Utenti").whereField("email", isEqualTo: email).whereField("password",isEqualTo: password).getDocuments { [weak self] querySnapshot, err  in
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
                    let nome : String = data["nome"] as? String ?? ""
                    let cognome: String = data["cognome"] as? String ?? ""
                    let eta: Int = data["eta"] as? Int ?? 0
                    let email: String = data["email"] as? String ?? ""
                    let password: String = data["password"] as? String ?? ""
                    let cellulare: String = data["cellulare"] as? String ?? ""
                    self.localUser = Utente(id: id, nome: nome, cognome: cognome, età: eta, email: email, password: password, cellulare: cellulare)
//                    per la pagina
                    ending?()
                }
                print(self.localUser)
            }
        }
    }
    
    func addFilm(film:Film,success:@escaping ()->Void) {
       
        firestore.collection("Film").addDocument(data: [
            "nome":film.nome,
            "url":film.url,
            "idUtente":film.idUtente,
            "thumbnail":film.thmbnail,
        ]){ [ weak self] err in
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
                success()
            }
        }
    }
    
   
    func addUtente(utente:Utente){
        self.addUtente(utente: utente) {
            print("Succes!!!")
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
   private func addUtente(utente: Utente,succes:@escaping ()->Void, failure:@escaping (Error) -> Void){
        
        firestore.collection("Utenti").addDocument(data: [
            "nome":utente.nome,
            "cognome":utente.cogome,
            "eta":utente.età,
            "email":utente.email,
            "password": utente.password,
            "cellulare":utente.cellulare,
        ]){ err in
            if let error = err{
                failure(error)
//                self.alertMessage = err!.localizedDescription
//                self.showAlert = true
            }else{
             succes()
            }
        
        }
       
    }
    
    
    func removeDocument(film:Film){
        self.removeDocument(film: film) {
            print("Success")
        } failure: { [weak self] error in
            guard let self = self else { return }
            self.alertMessage = error.localizedDescription
            self.showAlert.toggle()
        }
    }
    
   private func removeDocument(film: Film, success:@escaping ()->Void, failure:@escaping (Error)->Void){
        firestore.collection("Film").document(film.id).delete { err in
            if let err = err{
                failure(err)
                print("Error removing document : \(err.localizedDescription)")
            }else{
                print("document successfully removed!")
                success()
            }
        }
    }
    
}
