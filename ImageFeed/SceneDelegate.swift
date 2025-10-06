//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by William White on 07.08.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = SplashViewController() 
        window?.makeKeyAndVisible()
    }
    

    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        if url.scheme == "imagefeed", let code = extractCode(from: url) {
            OAuth2Service.shared.fetchOAuthToken(code: code) { result in
                switch result {
                case .success(let token):
                    print(" OAuth: \(token)")
                    NotificationCenter.default.post(name: .didAuthenticate, object: nil)
                case .failure(let error):
                    print("Error OAuth: \(error)")
                }
            }
        }
    }
    
    private func extractCode(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.queryItems?.first(where: { $0.name == "code" })?.value
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
