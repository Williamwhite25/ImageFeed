import Foundation

enum Constants {
    static let accessKey = "ZTqejhbBbm1cPD1rI-jfR2AQ0QG3GSfvd2BufWNmJyI"
    static let secretKey = "9e27wpuY9hjAaDBBXupMux1sy7RcgAplTzkzJ2dUyTo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid base URL")
        }
        return url
    }()
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         authURLString: String,
         defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: Constants.defaultBaseURL
        )
    }
}
