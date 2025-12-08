//
//  UploadRR.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 05/12/25.
//

import Foundation

struct UploadFilmResponse: Decodable {
    var url: String
    var fileName: String
    
    var completeURL: String {
        ApiManager.shared.generateUrlForStream(url: url)
    }
}
