//
//  Extensions.swift
//  VideoOnThemand
//
//  Created by Michele Manniello on 09/08/22.
//

import SwiftUI
import Cocoa
import Alamofire
import AVKit

class Extensions{
    
    static func isConnectedToInternet()->Bool{
        return NetworkReachabilityManager()!.isReachable
    }
    
   static func getDocumentsDirectory() -> URL{
 //        find all possible documents directories for ths user
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
 //        Just send back the first one, witch ought to be only one
         return paths[0]
     }
    
//    MARK: Creating Thumbnail by url
    static func createThumbnail(url : URL)  -> NSImage? {
        do {
        let asset = AVURLAsset(url: url,options: nil)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 2.5, preferredTimescale: 600), actualTime: nil)
        let thumbnail = NSImage(cgImage: cgImage,size: NSSize(width: 200, height: 200))
        return thumbnail
        
    } catch let error {
        print("☠️ Err generating thumbnail:\(error.localizedDescription) ")
        return nil
    }
}
    
   static func stringToDouble(value: Double) -> String {
        return String(format: "%.2f", value)
    }
  
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static  func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }

        // almeno una maiuscola,
        // almeno una cifra
        // almeno una minuscola
        // 8 caratteri in totale
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
  static  func getThumbnailName(nameOfElement: String)-> String{
      let fileNames = nameOfElement.split(separator: ".")
      return  "thumbnail_\(fileNames[0]).png"
      
    }
   
}
