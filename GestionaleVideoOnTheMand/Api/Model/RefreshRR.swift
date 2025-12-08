//
//  RefreshRR.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 05/12/25.
//

import Foundation
struct RefreshResponse: Decodable {
    var accessToken: String
}


struct RefreshBodyRequest: Encodable {
    var token: String
}
