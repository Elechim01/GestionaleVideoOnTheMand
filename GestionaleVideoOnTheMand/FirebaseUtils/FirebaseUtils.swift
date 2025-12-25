//
//  FirebaseUtils.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 07/12/25.
//

import Foundation
import Firebase
import AuthenticationServices

/*class FirebaseUtils: FirebaseProtocol {
    
    
    
    func singIn(email: String, password: String) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "FirebaseAuth",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Auth result nil"]
                        )
                    )
                }
            }
        }
    }
    
    func recuperoUtente(email: String, password: String, id: String) async throws -> Utente? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Utente?, Error>) in
            recuperoUtente(firestore: firestore, email: email, password: password) { querySnapshot, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let snapshot = querySnapshot else {
                    continuation.resume(throwing: CustomError.genericError)
                    return
                }
                
                // We expect at most one user document.
                guard snapshot.documents.count <= 1 else {
                    continuation.resume(throwing: CustomError.genericError)
                    return
                }
                
                // If no document is found, return nil (meaning “user not found”).
                guard let document = snapshot.documents.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Use the already‑unwrapped document.
                let data = document.data()
                
                guard let user = Utente.getUser(json: data) else {
                    continuation.resume(throwing: CustomError.fileError)
                    return
                }
                continuation.resume(returning: user)
            }
        }
    }
    
    func recuperoFilms(localUserId: String) -> AsyncStream<[Film]> {
        
        AsyncStream { continuation in
            recuperoFilms(firestore: firestore, localUser: localUserId) { documents in
                var films: [Film] = documents.compactMap { document in
                    guard var film = Film.getFilm(json: document.data()) else { return nil }
                    film.id = document.documentID
                  return film
                    
                }.sorted(by:{ $0.nome.compare($1.nome,options: .caseInsensitive) == .orderedAscending })
                #if DEV
                films.forEach { print("\($0.nome)") }
                #endif
                continuation.yield(films)
             } failure: { error in
                 continuation.yield([])
             }
            
        }
   }
    
    func addFilm(film:Film) async throws {
        
        return try await withCheckedThrowingContinuation { continuation in
            addFilm(firestore: firestore, film: film) { erro in
              
                if let error = erro  {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    
    func addUtente(utente:Utente) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.addUtente(firestore: firestore, utente: utente) {
                continuation.resume()
            } failure: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func removeDocument(film:Film) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.removeDocument(firestore: firestore, film: film) {
                continuation.resume()
            } failure: {  error in
                continuation.resume(throwing: error)
            }
        }
        
       
    }
    
}*/
