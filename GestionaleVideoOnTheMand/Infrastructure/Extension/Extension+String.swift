//
//  Utilstring.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 10/01/26.
//

import Foundation

// MARK: - String extension

extension String {
    static func twoDecimalMB(number: Double) -> String {
        String(format: "%.2f MB", number)
    }
    
    static func twoDecimalGB(number: Double) -> String {
        String(format: "%.2f GB", number)
    }
}
