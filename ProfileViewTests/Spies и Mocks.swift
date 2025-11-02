

import XCTest
import UIKit
@testable import ImageFeed

// MARK: - View Spy
final class MockProfileView: ProfileViewProtocol {
    var displayedName: String?
    var displayedLogin: String?
    var displayedBio: String?
    var displayedAvatarURL: URL?
    var didShowLogoutConfirmation = false
    var lastConfirmAction: (() -> Void)?

    func displayName(_ name: String) { displayedName = name }
    func displayLogin(_ login: String) { displayedLogin = login }
    func displayBio(_ bio: String) { displayedBio = bio }
    func displayAvatar(url: URL?) { displayedAvatarURL = url }
    func showLogoutConfirmation(title: String, message: String, confirmAction: @escaping () -> Void) {
        didShowLogoutConfirmation = true
        lastConfirmAction = confirmAction
    }
}

// MARK: - Presenter Spy (for ViewController test)
final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() { viewDidLoadCalled = true }
    func didTapLogoutButton() {}
    func didChangeAvatarURL(_ urlString: String?) {}
}

// MARK: - Service Mocks
final class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
}

final class MockImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    let didChangeNotification: Notification.Name = Notification.Name("MockProfileImageServiceDidChange")
}

final class MockLogoutService: ProfileLogoutServiceProtocol {
    var didLogout = false
    func logout() { didLogout = true }
}
