//
//  ExtensionEnvironment.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 10/01/26.
//

import Foundation
import SwiftUI
// MARK: - EnvironmentValues extension

extension EnvironmentValues {
    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
