import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?

    private init() {}

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard !token.isEmpty else {
            let errorMessage = "[ProfileService.fetchProfile]: EmptyTokenError"
            print(errorMessage)
            completion(.failure(NSError(domain: "ProfileService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token is missing or invalid"])))
            return
        }

        guard let request = makeProfileRequest(token: token) else {
            let errorMessage = "[ProfileService.fetchProfile]: InvalidRequest - токен \(token)"
            print(errorMessage)
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                defer { self?.task = nil }  

                switch result {
                case .success(let profileResult):
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName ?? "")",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    let errorMessage = "[ProfileService.fetchProfile]: \(error.localizedDescription) - токен \(token)"
                    print(errorMessage)
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService]: Ошибка создания URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

