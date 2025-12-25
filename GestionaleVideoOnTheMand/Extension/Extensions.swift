//
//  Extensions.swift
//  VideoOnThemand
//
//  Created by Michele Manniello on 09/08/22.
//

import SwiftUI
import Cocoa
import AVKit
import SystemConfiguration

class Extensions {
    
    static func isConnectedToInternet() -> Bool {
        return Reachability.isConnectedToNetwork()
    }
    
    static func getDocumentsDirectory() -> URL {
        // find all possible documents directories for the user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // Just send back the first one, which ought to be only one
        return paths[0]
    }
    
    // MARK: Creating Thumbnail by URL (async)
    static func createThumbnail(url: URL) async -> NSImage? {
        do {
            let asset = AVURLAsset(url: url, options: nil)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Load the duration using the modern async API.
            let duration: CMTime = try await asset.load(.duration)
            let seconds = min(10, duration.seconds / 2)
            
            let cgImage = try imageGenerator.copyCGImage(
                at: CMTime(seconds: seconds, preferredTimescale: 600),
                actualTime: nil
            )
            let thumbnail = NSImage(cgImage: cgImage,
                                   size: NSSize(width: 200, height: 200))
            return thumbnail
        } catch {
            print("☠️ Err generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func stringToDouble(value: Double) -> String {
        return String(format: "%.2f", value)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPassword(testStr: String?) -> Bool {
        guard testStr != nil else { return false }
        // almeno una maiuscola,
        // almeno una cifra
        // almeno una minuscola
        // 8 caratteri in totale
        let passwordTest = NSPredicate(
            format: "SELF MATCHES %@",
            "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        )
        return passwordTest.evaluate(with: testStr)
    }
    
    static func getThumbnailName(nameOfElement: String) -> String {
        let fileNames = nameOfElement.split(separator: ".")
        return "thumbnail_\(fileNames[0]).png"
    }
}

// MARK: - EnvironmentValues extension

extension EnvironmentValues {
    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

// MARK: - String extension

extension String {
    static func twoDecimal(number: Double) -> String {
        String(format: "%.2fMB", number)
    }
}

// MARK: - Reachability helper (private)

private class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }
}

// MARK: - View placeholder helper

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
