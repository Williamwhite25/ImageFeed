import Foundation

enum Constants {
    static let accessKey = "ZTqejhbBbm1cPD1rI-jfR2AQ0QG3GSfvd2BufWNmJyI"
    static let secretKey = "9e27wpuY9hjAaDBBXupMux1sy7RcgAplTzkzJ2dUyTo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
<<<<<<< HEAD
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid base URL")
=======
    
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("Invalid base URL string for Unsplash API")
>>>>>>> d5e9bcf49a06540daeebccb1100a45df8f5f2041
        }
        return url
    }()
}
