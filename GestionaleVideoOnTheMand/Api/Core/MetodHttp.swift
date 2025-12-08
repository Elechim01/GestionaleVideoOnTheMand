//
//  MetodHttp.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 30/11/25.
//

import Foundation

/// Represents the HTTP methods supported by the app.
///
/// Using a `String` raw value gives each case its canonical HTTP verb automatically,
/// while keeping the case names lower‑camel‑cased as recommended by Swift guidelines.
enum HTTPMethodType: String, CaseIterable {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
    
    /// Returns the raw string value of the HTTP method.
    var stringValue: String { self.rawValue }
}
