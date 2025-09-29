import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private init() {}

    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var isFetching = false

    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard !isFetching else { return }
        isFetching = true

        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            let errorMessage = "[ProfileImageService.fetchProfileImageURL]: AuthorizationError - отсутствует токен"
            print(errorMessage)
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            isFetching = false
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            let errorMessage = "[ProfileImageService.fetchProfileImageURL]: InvalidRequest - имя пользователя \(username)"
            print(errorMessage)
            completion(.failure(URLError(.badURL)))
            isFetching = false
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                defer { self?.isFetching = false }

                switch result {
                case .success(let userResult):
                    guard let self = self else { return }
                    self.avatarURL = userResult.profileImage.small
                    completion(.success(userResult.profileImage.small))

                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage.small]
                    )

                case .failure(let error):
                    let errorMessage = "[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription) - имя пользователя \(username)"
                    print(errorMessage)
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService]: Ошибка создания URL для пользователя \(username)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


