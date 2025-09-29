import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private var currentTask: URLSessionTask?
    private var currentCode: String?
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if currentCode == code {
            let errorMessage = "[OAuth2Service.fetchOAuthToken]: RequestAlreadyInProgress - код \(code)"
            print(errorMessage)
            completion(.failure(NetworkError.requestAlreadyInProgress))
            return
        }
        
        currentTask?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let errorMessage = "[OAuth2Service.fetchOAuthToken]: InvalidRequest - код \(code)"
            print(errorMessage)
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        UIBlockingProgressHUD.show()
        
        currentCode = code
        currentTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                self.currentTask = nil
                self.currentCode = nil
                
                switch result {
                case .success(let responseBody):
                    OAuth2TokenStorage.shared.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    let errorMessage = "[OAuth2Service.fetchOAuthToken]: \(error.localizedDescription) - код \(code)"
                    print(errorMessage)
                    completion(.failure(error))
                }
            }
        }
        
        currentTask?.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = makeHttpBody(from: params)
        return request
    }
    
    private func makeHttpBody(from params: [String: String]) -> Data? {
        let bodyString = params
            .map { key, value in
                let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
                let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(k)=\(v)"
            }
            .joined(separator: "&")
        
        return bodyString.data(using: .utf8)
    }
}



