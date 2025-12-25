import Foundation

final class ApiManager {

    static let shared = ApiManager()
    private static let baseUrl = "http://192.168.1.119:3000"
    
    var token: String? {
        get {
            KeychainService.shared.read("token")
        }
        set {
            if let newValue = newValue {
                KeychainService.shared.save(newValue, for: "token")
            } else {
                KeychainService.shared.delete("token")
            }
        }
    }
    
    
    var refreshToken: String? {
            get { KeychainService.shared.read("refreshToken") }
            set {
                if let newValue = newValue {
                    KeychainService.shared.save(newValue, for: "refreshToken")
                } else {
                    KeychainService.shared.delete("refreshToken")
                }
            }
        }

    private let endpoints = APIEndpoints(
        baseURL: URL(string: baseUrl)!
    )

    // Example of accessing an endpoint:
    var tokenURL: URL { endpoints.token }
    var refreshTokenURL: URL { endpoints.refreshToken }
    var uploadFileURL: URL { endpoints.uploadFile }

    func deleteFileURL(fileName: String) -> URL {
        endpoints.deleteFile(fileName)
    }

    func getFileURL(fileName: String) -> URL {
        endpoints.getFile(fileName)
    }
    
    func generateUrlForStream(url: String) -> String {
        Self.baseUrl + url
    }
}
