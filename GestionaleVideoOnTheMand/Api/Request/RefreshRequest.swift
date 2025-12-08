//
//  RefreshRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 05/12/25.
//

import Foundation

struct RefreshRequest: APIRequest {
    typealias Response = RefreshResponse
    
    var requestURL: URL { ApiManager.shared.refreshTokenURL }
    
    var method: HTTPMethodType { .post }
    
    var headers: [String : String] {["Content-Type": "application/json"]}
    
    var body: Data? {
        try? JSONEncoder().encode(refreshBody)
    }
    
    var refreshBody: RefreshBodyRequest
    init(refreshBody: RefreshBodyRequest) {
        self.refreshBody = refreshBody
    }
    
    func performRequest(success:@escaping () -> (),failure : @escaping(Error) -> ()) {
        self.perform { result in
            switch result {
            case .success(let success):
                ApiManager.shared.token = success.accessToken
                
            case .failure(let error):
                failure(error)
            }
        }
    }
    
}
