//
//  CustomError.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation

/// Centralised error type for the application.
enum CustomError: LocalizedError, CustomStringConvertible {
    
    // MARK: - Existing cases
    
    /// The supplied URL string could not be turned into a valid `URL`.
    case invalidURL(urlString: String)
    
    /// The app failed to create a temporary file.
    /// - Parameters:
    ///   - directory: The location where the temporary file was to be created.
    ///   - underlyingError: The underlying system error, if any.
    case temporaryFileCreationFailed(directory: URL, underlyingError: Error?)
    
    /// A generic fallback for errors that don’t fit a specific case.
    case unknown
    
    // MARK: - New cases requested by the user
    
    /// A generic, non‑specific error.
    case genericError
    
    /// An error related to file handling (e.g., read/write failures).
    case fileError
    
    /// An error indicating that the device has no internet connection.
    case connectionError
    
    /// no refrsh token
    case missingRefreshToken
    
    
    /// response status code error
    
    // MARK: - CustomStringConvertible conformance
    
    /// Human‑readable description used when the enum is printed or when a simple
    /// description is desired (e.g., UI labels).
    var description: String {
        switch self {
        case .genericError:
            return "Generic Error"
        case .fileError:
            return "File Error"
        case .connectionError:
            return "Il dispositivo non è connesso a internet"
        case .invalidURL(let urlString):
            return "The URL “\(urlString)” is not valid."
        case .temporaryFileCreationFailed(let directory, let underlyingError):
            var msg = "Unable to create a temporary file in “\(directory.path)”."
            if let underlyingError = underlyingError {
                msg += " System error: \(underlyingError.localizedDescription)"
            }
            return msg
        case .unknown:
            return "An unknown error occurred."
        case .missingRefreshToken:
            return "no refreshToken"
        }
    }
    
    // MARK: - LocalizedError conformance
    
    /// A user‑friendly description of the error (used by `NSError` bridges,
    /// alerts, etc.).
    var errorDescription: String? {
        // Re‑use `description` for the textual content.
        description
    }
    
    /// A suggestion that might help the user recover from the error.
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check the URL format and try again."
        case .temporaryFileCreationFailed:
            return "Ensure the app has write permission to the target directory."
        case .connectionError:
            return "Check your internet connection and retry."
        case .fileError:
            return "Verify that the file exists and the app has appropriate permissions."
        case .genericError, .unknown:
            return nil
        case .missingRefreshToken:
            return "Unistall app"
        }
    }
}


// implementare il decodable

struct ApiError: Error {
    let statusCode: Int?
    let error: Error
}
