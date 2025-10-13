

import Foundation
import Kingfisher
import SwiftKeychainWrapper


final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var isLoading = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    var onPhotosUpdated: (() -> Void)?
    
    func fetchPhotosNextPage(with token: String) {
        guard !isLoading else { return }
        isLoading = true

        let nextPage = lastLoadedPage + 1
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isLoading = false }

            if let error = error {
                print("Error fetching photos: \(error)")
                return
            }

            guard let data = data else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let photoResults = try decoder.decode([PhotoResult].self, from: data)

                let newPhotos = photoResults.map { Photo(from: $0) }
                self?.photos.append(contentsOf: newPhotos)
                self?.lastLoadedPage = nextPage

                // Обновляем UI на главном потоке
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Error decoding photos: \(error)")
            }
        }
        task.resume()
    }

    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        let urlString = "\(Constants.defaultBaseURL)/photos?page=\(page)"
        guard let url = URL(string: urlString) else {
            print("[ImagesListService]: Ошибка создания URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}






//
//import Foundation
//
//final class ImagesListService {
//    private(set) var photos: [Photo] = []
//    private var lastLoadedPage: Int = 0
//    private var isLoading = false
//    
//    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
//    
//    var onPhotosUpdated: (() -> Void)?
//    
//    func fetchPhotosNextPage() {
//        guard !isLoading else { return }
//        isLoading = true
//
//        let nextPage = lastLoadedPage + 1
//
//        let urlString = "\(Constants.defaultBaseURL)/photos?page=\(nextPage)&client_id=\(Constants.accessKey)"
//        guard let url = URL(string: urlString) else {
//            isLoading = false
//            return
//        }
//
//       
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            defer { self?.isLoading = false }
//
//            if let error = error {
//                print("Error fetching photos: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                return
//            }
//
//            
//            do {
//                let decoder = JSONDecoder()
//                let photoResults = try decoder.decode([PhotoResult].self, from: data)
//                
//               
//                let newPhotos = photoResults.map { Photo(from: $0) }
//                self?.photos.append(contentsOf: newPhotos)
//                self?.lastLoadedPage = nextPage
//
//                // Обновляем UI на главном потоке
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
//                }
//            } catch {
//                print("Error decoding photos: \(error)")
//            }
//        }
//        task.resume()
//    }
//}
