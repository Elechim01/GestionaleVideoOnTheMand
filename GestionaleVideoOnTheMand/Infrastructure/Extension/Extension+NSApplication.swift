//
//  Extension+NSApplication.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 25/03/26.
//

import Foundation
import AppKit

extension NSApplication{
    
//    Root Controller
    func rootController() -> NSViewController {
        guard let window =  windows.first as? NSWindow else { return .init() }
        guard let viewController = window.contentViewController else {return .init()}
        return viewController
    }
}
