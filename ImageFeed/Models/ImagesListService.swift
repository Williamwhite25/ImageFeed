
import Foundation
import Kingfisher
import SwiftKeychainWrapper

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var isLoading = false
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    var onPhotosUpdated: (() -> Void)?
    
    func clear() {
        photos.removeAll()
        lastLoadedPage = 0
        isLoading = false
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
            self.onPhotosUpdated?()
        }
    }
    
    private func dataSnippet(data: Data) -> String {
        let maxLen = 1000
        let text = String(data: data, encoding: .utf8) ?? "<binary data>"
        return text.count > maxLen ? String(text.prefix(maxLen)) + "…(truncated)" : text
    }
    
    func fetchPhotosNextPage(with token: String) {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = lastLoadedPage + 1
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            isLoading = false
            print("[ImagesListService.fetchPhotosNextPage]: BadRequest page:\(nextPage) tokenPresent:\(OAuth2TokenStorage.shared.token != nil)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }
            let methodTag = "ImagesListService.fetchPhotosNextPage"
            
            if let error = error {
                print("[\(methodTag)]: NetworkError page:\(nextPage) error:\(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("[\(methodTag)]: NoData page:\(nextPage)")
                return
            }
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let snippet = self?.dataSnippet(data: data) ?? String(data: data.prefix(200), encoding: .utf8) ?? "<binary data>"
                print("[\(methodTag)]: HTTPError page:\(nextPage) status:\(http.statusCode) snippet:\(snippet)")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.map { Photo(from: $0) }
                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: newPhotos)
                    self?.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    self?.onPhotosUpdated?()
                }
            } catch {
                let snippet = self?.dataSnippet(data: data) ?? "<no data>"
                print("[\(methodTag)]: DecodingError page:\(nextPage) error:\(error.localizedDescription) snippet:\(snippet)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let methodTag = "ImagesListService.changeLike"
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[\(methodTag)]: NoToken photoId:\(photoId) isLike:\(isLike)")
            DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No token"]))) }
            return
        }
        
        let urlString = "\(Constants.defaultBaseURL)/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("[\(methodTag)]: BadURL photoId:\(photoId) isLike:\(isLike) url:\(urlString)")
            DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bad URL"]))) }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("[\(methodTag)]: NetworkError photoId:\(photoId) isLike:\(isLike) error:\(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let snippet: String
                if let d = data {
                    if let s = self?.dataSnippet(data: d) {
                        snippet = s
                    } else {
                        snippet = String(data: Data(d.prefix(200)), encoding: .utf8) ?? "<no body>"
                    }
                } else {
                    snippet = "<no body>"
                }
                print("[\(methodTag)]: HTTPError photoId:\(photoId) isLike:\(isLike) status:\(http.statusCode) snippet:\(snippet)")
                let err = NSError(domain: "", code: http.statusCode, userInfo: nil)
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            var likedByUserFromResponse: Bool? = nil
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let photoResult = try decoder.decode(PhotoResult.self, from: data)
                    likedByUserFromResponse = photoResult.likedByUser
                } catch {
                    let snippet = self?.dataSnippet(data: data) ?? "<no data>"
                    print("[\(methodTag)]: DecodingError photoId:\(photoId) isLike:\(isLike) error:\(error.localizedDescription) snippet:\(snippet)")
                }
            }
            
            guard let self = self else {
                print("[\(methodTag)]: SelfDeallocated photoId:\(photoId) isLike:\(isLike)")
                DispatchQueue.main.async { completion(.failure(NSError(domain: "", code: 0, userInfo: nil))) }
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newIsLiked = likedByUserFromResponse ?? !photo.isLiked
                    var newPhoto = photo
                    newPhoto.isLiked = newIsLiked
                    self.photos[index] = newPhoto
                }
                
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                self.onPhotosUpdated?()
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        let urlString = "\(Constants.defaultBaseURL)/photos?page=\(page)"
        guard let url = URL(string: urlString) else {
            print("[ImagesListService.makePhotosRequest]: BadURL page:\(page) url:\(urlString)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}












