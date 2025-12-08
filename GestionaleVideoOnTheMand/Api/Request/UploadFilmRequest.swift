//
//  UploadRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 05/12/25.
//

import Foundation

struct UploadFilmRequest: UploadRequest {
    
    typealias Response = UploadFilmResponse
    
    var requestURL: URL { ApiManager.shared.uploadFileURL }
    
    var file: URL
    
    var headers: [String : String] { [:]}
    
    
    init(file: URL) {
        self.file = file
    }
    
    struct UploadFilmResult {
        let response: Response?
        let progress: Double?
        let error: Error?
    }
    
    func uploadFilmAsync()-> AsyncStream<UploadFilmResult>  {
        AsyncStream { continuation in
            self.perform { progress in
                continuation.yield(UploadFilmResult(response: nil, progress: progress, error: nil))
            } completion: { result in
                switch result {
                case .success(let response):
                    continuation.yield(UploadFilmResult(response: response, progress: 1.0, error: nil))
                    continuation.finish()
                case .failure(let error):
                    continuation.yield(UploadFilmResult(response: nil, progress: 1.0, error: error))
                    continuation.finish()
                }
            }
        }
    }
    
    func uploadFilm(progress: @escaping (Double) ->Void, onSuccess: @escaping (Response) -> Void , onError: @escaping (Error) -> Void) {
        self.perform(progress: progress) { result in
            switch result {
            case .success(let success):
                print(success.url)
                onSuccess(success)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
}
