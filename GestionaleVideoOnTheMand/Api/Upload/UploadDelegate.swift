//
//  UploadDelegate.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation

final class UploadDelegate: NSObject, URLSessionTaskDelegate {
    private let progress: (Double)-> Void
    
    init(progress: @escaping (Double) -> Void) {
        self.progress = progress
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let fraction = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.progress(fraction * 100)
        }
    }
}
