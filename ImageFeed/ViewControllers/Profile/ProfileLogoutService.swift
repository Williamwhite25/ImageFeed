

import Foundation
import WebKit
import Kingfisher
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() {}
    
    func logout() {
        // 1. Очистка токена
        OAuth2TokenStorage.shared.token = nil
        
        // 2. Очистка сервисов
        ProfileService.shared.clear()
        ProfileImageService.shared.clear()
        ImagesListService.shared.clear()
        
        // 3. Очистка кэша Kingfisher
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache(completion: nil)
        
        // 4. Удаление cookie и веб-данных
        cleanCookies()
        
        // 5. Переход на стартовый экран (Splash)
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            let splash = SplashViewController()
            UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromLeft]) {
                window.rootViewController = splash
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                dataStore.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
