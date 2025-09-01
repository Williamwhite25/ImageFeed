import Foundation

enum Constants {
    static let accessKey = "ZTqejhbBbm1cPD1rI-jfR2AQ0QG3GSfvd2BufWNmJyI"
    static let secretKey = "9e27wpuY9hjAaDBBXupMux1sy7RcgAplTzkzJ2dUyTo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("Invalid base URL string for Unsplash API")
        }
        return url
    }()
}
