import Foundation

/// A small value‑type that knows how to construct the various URLs used by the backend.
struct APIEndpoints {
    /// The base URL of the server (e.g. `http://192.168.1.100:3000`).
    let baseURL: URL

    /// `…/token`
    var token: URL {
        baseURL.appendingPathComponent("token")
    }

    /// `…/refresh`
    var refreshToken: URL {
        baseURL.appendingPathComponent("refresh")
    }

    /// `…/upload`
    var uploadFile: URL {
        baseURL.appendingPathComponent("upload")
    }

    /// `…/media/<fileName>`
    func deleteFile(_ fileName: String) -> URL {
        baseURL.appendingPathComponent("media/\(fileName)")
    }

    /// `…/download/<fileName>`
    func getFile(_ fileName: String) -> URL {
        baseURL.appendingPathComponent("download/\(fileName)")
    }
}
