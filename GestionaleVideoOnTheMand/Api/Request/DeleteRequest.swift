//
//  DeleteRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 08/12/25.
//

import Foundation

struct DeleteRequest: APIRequest {
    typealias Response = DeleteResponse
    
    var requestURL: URL
    
    var method: HTTPMethodType = .delete
    
    var headers: [String : String] = [:]
    
    var body: Data? = nil
    
    init(fileName: String) {
        requestURL = ApiManager.shared.deleteFileURL(fileName: fileName)
    }
    
    func performAsync() async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.performWithToken { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
}
