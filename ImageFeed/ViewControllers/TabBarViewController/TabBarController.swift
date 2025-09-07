
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarIcons()
        setupNavigationAppearance()
    }
    
    // MARK: TAPBAR
    
    private func setupTabBarIcons() {
        guard let items = tabBar.items else { return }
        
        
        items[0].image = UIImage(named: "ImageListTapBar")
        items[0].selectedImage = UIImage(named: "ImageListTapBarActive")
        items[0].title = ""
        
        
        items[1].image = UIImage(named: "ProfileTabBar")
        items[1].selectedImage = UIImage(named: "ProfileTapBarActive")
        items[1].title = ""
        
        
        
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        tabBar.standardAppearance = appearance
    }
    
    // MARK: NAVIGATION
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        UINavigationBar.appearance().tintColor = .white
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

