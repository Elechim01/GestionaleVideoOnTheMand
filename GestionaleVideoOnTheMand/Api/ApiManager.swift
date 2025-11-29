//
//  ApiManager.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 29/11/25.
//

import Foundation

// Change to protocolo with extension
class ApiManager {
    let apiUrl: String = "http://192.168.1.100:3000"
    
    func getToken(paramsToken: ParamsToken) {
    
        let tokenURL: String = apiUrl + "/token"
        guard let url  = URL(string: tokenURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try? JSONEncoder().encode(paramsToken)
        
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Error: \(error)")
                
            } else {
                
                // Status code
                guard let httpResponse = response as? HTTPURLResponse else {
                        return
                    }
                print("Status Code")
                print(httpResponse.statusCode)
                
                
                if let data {
                   let param =  try? JSONDecoder().decode(ParamRespone.self, from: data)
                    print(param?.token)
                    print(param?.refreshToken)
                }
            }
        }.resume()
    }
}

struct ParamsToken: Codable {
    var username: String
    var password: String
}

struct ParamRespone: Codable {
    var token: String
    var refreshToken: String
}
