//
//  UploadRequest.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation
import UniformTypeIdentifiers

protocol UploadRequest {
    associatedtype Response: Decodable
    var requestURL: URL { get }
    var file: URL { get }
    var headers: [String: String] { get }
    func perform(progress: @escaping(Double)-> Void, completion: @escaping(Result<Response, Error>) -> Void)
}

extension UploadRequest {
    func perform(progress: @escaping(Double)-> Void,
                 completion: @escaping(Result<Response, Error>) -> Void) {
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethodType.post.stringValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        guard let token = ApiManager.shared.token else {
            // sostituire con tokenNotValid
            completion(.failure(ApiError(statusCode: nil, error: CustomError.unknown)))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Creazione file multipart su disco
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("\(boundary).tmp")
        do {
            try Data().write(to: tempFile)
            let output = try FileHandle(forWritingTo: tempFile)
            let input = try FileHandle(forReadingFrom: file)
            let filename = file.lastPathComponent
            let mime = file.mimeType
            
            let header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: \(mime)\r\n\r\n"
            try output.write(contentsOf: Data(header.utf8))
            
            let chunkSize = 64 * 1024
            while let chunk = try input.read(upToCount: chunkSize), !chunk.isEmpty {
                try output.write(contentsOf: chunk)
            }
            
            try output.write(contentsOf: Data("\r\n--\(boundary)--\r\n".utf8))
            output.closeFile()
            input.closeFile()
        } catch {
            print("Errore creazione file multipart:", error)
            try? FileManager.default.removeItem(at: tempFile)
            completion(.failure(CustomError.temporaryFileCreationFailed(directory: tempFile, underlyingError: error)))
            return
        }
        
      let box = UploadSessionBox(progress: progress)
        box.session.uploadTask(with: request, fromFile: tempFile) { data, response, error in
            try? FileManager.default.removeItem(at: tempFile)

            if let error {
                completion(.failure(error))
                return
            }
            
            guard  let httpResponse = response as? HTTPURLResponse else {
            
                return
            }
            if httpResponse.statusCode == 401 {
                self.handleRefreshAndRetry(progress: progress, completion: completion)
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "ApiManager", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let responseData: Response = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
        
    }
    
    private func handleRefreshAndRetry(
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<Response, Error>) -> Void,
    ) {
        guard let refreshToken = ApiManager.shared.refreshToken else {
                completion(.failure(CustomError.missingRefreshToken))
                return
            }
        
        let refreshRequest = RefreshRequest(refreshBody: RefreshBodyRequest(token: refreshToken))
        
        refreshRequest.performRequest {
            self.perform(progress: progress, completion: completion)
        } failure: { error in
            completion(.failure(error))
        }
    }
    
}

extension URL {
    var mimeType: String {
        let ext = self.pathExtension.lowercased()
        guard let utType = UTType(filenameExtension: ext)?.preferredMIMEType else {
            return "application/octet-stream"
        }
        return utType
    }
}
