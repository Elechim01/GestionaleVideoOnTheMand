//
//  TokenRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 01/12/25.
//

import Foundation

struct TokenRequest: APIRequest {
    
    typealias Response = TokenResponse
    
    var requestURL: URL {ApiManager.shared.tokenURL }
    
    var method: HTTPMethodType  { .post }
    
    var headers: [String : String]  { ["Content-Type": "application/json"] }
    
    var body: Data? {
        try? JSONEncoder().encode(tokenBody)
    }
    
    var tokenBody: TokenBodyRequest
    
    init(tokenBody: TokenBodyRequest) {
        self.tokenBody = tokenBody
    }
    
    
    func performRequestAsync() async throws {
        let response = try await performAsync()
        ApiManager.shared.token = response.token
        ApiManager.shared.refreshToken = response.refreshToken
    }
    
   private func performAsync() async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.perform { result in
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
    


