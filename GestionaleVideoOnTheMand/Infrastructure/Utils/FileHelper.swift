//
//  FileHelper.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 23/03/26.
//

import Foundation
import AVKit
import Cocoa

class FileHelper {
    
    @MainActor
    static func selectMovies() -> [UploadItem] {
        let pannell = NSOpenPanel()
        pannell.allowedContentTypes = [.movie]
        pannell.allowsMultipleSelection = true
        pannell.canChooseDirectories = false
        if pannell.runModal() == .OK {
            var selectedMetadata: [UploadItem] = []
            for url in pannell.urls {
                
                if let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
                   let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                    let dimensionsMB = Double(fileSize) / (1024*1024)
                    selectedMetadata.append(UploadItem(url: url,
                                                       name: url.lastPathComponent,
                                                       size: dimensionsMB))
                }
            }
            return selectedMetadata
            
        }
        return []
    }
    
}
