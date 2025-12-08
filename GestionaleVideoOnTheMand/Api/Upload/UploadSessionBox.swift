//
//  UploadSessionBox.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation

final class UploadSessionBox {
    let session: URLSession
    let delegate: UploadDelegate
    
    init(progress: @escaping (Double) -> Void) {
            self.delegate = UploadDelegate(progress: progress)
            self.session = URLSession(configuration: .default,
                                      delegate: delegate,
                                      delegateQueue: nil)
        }
}
