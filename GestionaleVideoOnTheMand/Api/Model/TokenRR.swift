//
//  TokenRR.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 01/12/25.
//

import Foundation

struct TokenResponse: Decodable {
    var token: String
    var refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case refreshToken = "refreshToken"
    }
    
}

struct TokenBodyRequest: Encodable{
    var username: String
    var password: String
}
