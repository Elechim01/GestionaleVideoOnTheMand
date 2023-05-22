//
//  HomeProtocol.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 20/05/23.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

protocol HomeProtocol {
    func deleteFile(firebaseStorage: Storage, localUser: String ,nomeFile: String, success:@escaping ()->Void, failure: @escaping (Error) -> Void)
    func recuperoFilms(firestore: Firestore, localUser: String,success:@escaping ([QueryDocumentSnapshot])->Void, failure:@escaping (Error) -> Void)
    
    func addFilm(firestore: Firestore,film: Film, completion: ((Error?) -> Void)?)
    
    func addUtente(firestore: Firestore,utente: Utente,succes:@escaping ()->Void, failure:@escaping (Error) -> Void)
    
    func removeDocument(firestore: Firestore,film: Film, success:@escaping ()->Void, failure:@escaping (Error)->Void)
    
    func recuperoUtente(firestore:Firestore,email: String, password:String, completion: @escaping (QuerySnapshot?, Error?) -> Void)
    
}

extension HomeProtocol {
    
    func deleteFile(firebaseStorage:Storage,localUser: String  ,nomeFile: String, success:@escaping ()->Void, failure: @escaping (Error) -> Void){
        let deleteRef = firebaseStorage.reference().child("\(localUser)/\(nomeFile)")
        deleteRef.delete { error in
            if let error = error{
                failure(error)
                
            }else{
                print("No Problem")
                success()
            }
        }
    }
    
    func recuperoFilms(firestore: Firestore, localUser: String, success:@escaping ([QueryDocumentSnapshot])->Void, failure:@escaping (Error) -> Void) {
        print(localUser)
        firestore.collection("Film").whereField("idUtente", isEqualTo: localUser).addSnapshotListener { querySnapshot, error in
            if let erro = error{
                failure(erro)
            }
            else{
                success(querySnapshot!.documents)
            }
        }
    }
    
    func addFilm(firestore: Firestore ,film: Film, completion: ((Error?) -> Void)?) {
        firestore.collection("Film").addDocument(data: [
            "nome":film.nome,
            "url":film.url,
            "idUtente":film.idUtente,
            "thumbnail":film.thmbnail,
        ],completion: completion)
    }
    
    func addUtente(firestore: Firestore,utente: Utente,succes:@escaping ()->Void, failure:@escaping (Error) -> Void) {
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
    
    func removeDocument(firestore: Firestore,film: Film, success:@escaping ()->Void, failure:@escaping (Error)->Void) {
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
    
    func recuperoUtente(firestore:Firestore,email: String, password:String, completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        firestore.collection("Utenti").whereField("email", isEqualTo: email).whereField("password",isEqualTo: password).getDocuments(completion: completion)
    }
}
