//
//  Steps.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 23/03/26.
//

import Foundation

struct Steps: Identifiable {
    var id: String = UUID().uuidString
    var type: UploadStatus
    var progress: Double
    var isComplete: Bool {
        progress == 100
    }
    
    init(type: UploadStatus) {
        self.type = type
        self.progress = 0.0
    }
    
}
