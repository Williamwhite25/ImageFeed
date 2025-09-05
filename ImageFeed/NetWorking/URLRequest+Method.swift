import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
    case head    = "HEAD"
    case options = "OPTIONS"
}

extension URLRequest {
    mutating func setMethod(_ method: HTTPMethod) {
        self.httpMethod = method.rawValue
    }
}
