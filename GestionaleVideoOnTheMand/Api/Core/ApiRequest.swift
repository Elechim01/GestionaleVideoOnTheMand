//
//  ApiRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    var requestURL: URL { get }
    var method: HTTPMethodType { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension APIRequest {
    
    func perform(completion: @escaping (Result<Response, ApiError>) -> Void) {
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.stringValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        request.httpBody = body
        
        // Create the data‑task, decode the response, and start it.
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(ApiError(statusCode: nil, error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let apiError = ApiError(statusCode: nil, error: NSError(domain: "ApiManager", code: -5,
                                                                        userInfo: [NSLocalizedDescriptionKey: "Response invalid"]))
                completion(.failure(apiError))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else  {
                
                completion(.failure(ApiError(statusCode: httpResponse.statusCode, error: CustomError.genericError)))
                return
            }
          
            guard let data else {
                let apiError = ApiError(statusCode: nil, error: NSError(domain: "ApiManager", code: -5,
                                                                        userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                completion(.failure(apiError))
                return
            }
            
            do {
                // Use the proper metatype `Response.self`
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(ApiError(statusCode: nil, error: error)))
            }
        }.resume()
    }
    
// TOKEN
    func performWithToken(retryOn401: Bool = true, completion: @escaping (Result<Response, ApiError>) -> Void) {
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.stringValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        if method != .delete {
            request.httpBody = body
        }
     
        
        // Add token
        guard let token = ApiManager.shared.token else {
            // sostituire con tokenNotValid
            completion(.failure(ApiError(statusCode: nil, error: CustomError.unknown)))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("Ritornato")
            if let error {
                completion(.failure(ApiError(statusCode: nil, error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let apiError = ApiError(statusCode: nil, error: NSError(domain: "ApiManager", code: -5,
                                                                        userInfo: [NSLocalizedDescriptionKey: "Response invalid"]))
                completion(.failure(apiError))
                return
            }
            if httpResponse.statusCode == 401  {
                RefreshRequest(refreshBody: RefreshBodyRequest(token: token)).performRequest {
                performWithToken(retryOn401: false, completion: completion)
                } failure: { error in
                    completion(.failure(ApiError(statusCode: nil, error: error)))
                }

                
            }
            
            guard let data else {
                let apiError = ApiError(statusCode: nil, error: NSError(domain: "ApiManager", code: -5,
                                                                        userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                completion(.failure(apiError))
                return
            }
            
            do {
                // Use the proper metatype `Response.self`
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(ApiError(statusCode: nil, error: error)))
            }
        }.resume()
        
        
        
    }
    
}


