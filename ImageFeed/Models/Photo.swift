
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool

    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = ISO8601DateFormatter().date(from: photoResult.createdAt)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser
    }
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult

    struct UrlsResult: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}



//import UIKit
//
//struct Photo: Decodable {
//    let id: String
//    let size: CGSize
//    let createdAt: Date?
//    let welcomeDescription: String?
//    let thumbImageURL: String
//    let largeImageURL: String
//    let isLiked: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case size
//        case createdAt
//        case welcomeDescription
//        case thumbImageURL
//        case largeImageURL
//        case isLiked
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        
// 
//        let sizeString = try container.decode(String.self, forKey: .size)
//        let dimensions = sizeString.split(separator: ",").compactMap { Double($0) }
//        if dimensions.count == 2 {
//            size = CGSize(width: dimensions[0], height: dimensions[1])
//        } else {
//            size = CGSize.zero 
//        }
//        
//        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
//        welcomeDescription = try container.decodeIfPresent(String.self, forKey: .welcomeDescription)
//        thumbImageURL = try container.decode(String.self, forKey: .thumbImageURL)
//        largeImageURL = try container.decode(String.self, forKey: .largeImageURL)
//        isLiked = try container.decode(Bool.self, forKey: .isLiked)
//    }
//}
