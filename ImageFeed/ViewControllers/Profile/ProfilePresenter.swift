import Foundation
import UIKit

// MARK: - View Protocol
protocol ProfileViewProtocol: AnyObject {
    func displayName(_ name: String)
    func displayLogin(_ login: String)
    func displayBio(_ bio: String)
    func displayAvatar(url: URL?)
    func showLogoutConfirmation(title: String, message: String, confirmAction: @escaping () -> Void)
}

// MARK: - Presenter Protocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func didChangeAvatarURL(_ urlString: String?)
}

// MARK: - Service Protocols
protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

protocol ProfileImageServiceProtocol: AnyObject {
    var avatarURL: String? { get }
    var didChangeNotification: Notification.Name { get }
}

protocol ProfileLogoutServiceProtocol: AnyObject {
    func logout()
}

// Adapt existing singletons (if present) to protocols
extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {
    var didChangeNotification: Notification.Name { Self.didChangeNotification }
}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

// MARK: - Presenter Implementation
final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?

    private let profileService: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private var observer: NSObjectProtocol?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.imageService = imageService
        self.logoutService = logoutService
    }

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.displayName(ProfileHelper.formattedName(from: profile))
            view?.displayLogin(ProfileHelper.formattedLogin(from: profile))
            view?.displayBio(ProfileHelper.formattedBio(from: profile))
        } else {
            view?.displayName(ProfileHelper.defaultName)
            view?.displayLogin(ProfileHelper.defaultLogin)
            view?.displayBio(ProfileHelper.defaultBio)
        }

        let url = ProfileHelper.avatarURL(from: imageService.avatarURL)
        view?.displayAvatar(url: url)

        observer = NotificationCenter.default.addObserver(
            forName: imageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let updatedURL = ProfileHelper.avatarURL(from: self.imageService.avatarURL)
            self.view?.displayAvatar(url: updatedURL)
        }
    }

    func didChangeAvatarURL(_ urlString: String?) {
        let url = ProfileHelper.avatarURL(from: urlString)
        view?.displayAvatar(url: url)
    }

    func didTapLogoutButton() {
        view?.showLogoutConfirmation(
            title: "Выйти из аккаунта?",
            message: "Вы уверены, что хотите выйти?"
        ) { [weak self] in
            self?.logoutService.logout()
        }
    }

    deinit {
        if let obs = observer {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}
