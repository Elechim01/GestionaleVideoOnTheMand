//
//  UploadItem.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 23/03/26.
//

import Foundation

struct UploadItem: Identifiable {
    let id: UUID = UUID()
    let url: URL
    let name: String
    let size: Double
    
}
