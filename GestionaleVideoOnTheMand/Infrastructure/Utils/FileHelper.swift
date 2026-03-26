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
    static func createTempFile(from image: NSImage, nameFile: String = "thumbnail", fileExtension:String = "png") -> URL {
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(nameFile).\(fileExtension)")
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: tempUrl)
        }
        return tempUrl
    }
    
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
                    //selectedMetadata[url] = (url.lastPathComponent,dimensionsMB)
                    
                    
                }
            }
            return selectedMetadata
            
        }
        return []
    }
    
}
