import XCTest
import UIKit
@testable import ImageFeed

final class ProfilePresenterTests: XCTestCase {
    func test_viewDidLoad_withProfile_callsViewDisplayMethods() {
        // given
        let profile = Profile(username: "Рик", name: "Морти", loginName: "@приключение", bio: "на 20 минут")
        let profileService = MockProfileService()
        profileService.profile = profile

        let imageService = MockImageService()
        imageService.avatarURL = "https://example.com/avatar.png"

        let logoutService = MockLogoutService()

        let presenter = ProfilePresenter(
            profileService: profileService,
            imageService: imageService,
            logoutService: logoutService
        )
        let view = MockProfileView()
        presenter.view = view

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertEqual(view.displayedName, ProfileHelper.formattedName(from: profile))
        XCTAssertEqual(view.displayedLogin, ProfileHelper.formattedLogin(from: profile))
        XCTAssertEqual(view.displayedBio, ProfileHelper.formattedBio(from: profile))
        XCTAssertEqual(view.displayedAvatarURL, URL(string: imageService.avatarURL!))
    }

    func test_viewDidLoad_withoutProfile_usesDefaults() {
        // given
        let profileService = MockProfileService()
        profileService.profile = nil

        let imageService = MockImageService()
        imageService.avatarURL = nil

        let logoutService = MockLogoutService()

        let presenter = ProfilePresenter(
            profileService: profileService,
            imageService: imageService,
            logoutService: logoutService
        )
        let view = MockProfileView()
        presenter.view = view

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertEqual(view.displayedName, ProfileHelper.defaultName)
        XCTAssertEqual(view.displayedLogin, ProfileHelper.defaultLogin)
        XCTAssertEqual(view.displayedBio, ProfileHelper.defaultBio)
        XCTAssertNil(view.displayedAvatarURL)
    }

    func test_didChangeAvatarURL_updatesView() {
        // given
        let presenter = ProfilePresenter(
            profileService: MockProfileService(),
            imageService: MockImageService(),
            logoutService: MockLogoutService()
        )
        let view = MockProfileView()
        presenter.view = view

        // when
        presenter.didChangeAvatarURL("https://example.com/new.png")

        // then
        XCTAssertEqual(view.displayedAvatarURL, URL(string: "https://example.com/new.png"))
    }

    func test_didTapLogoutButton_showsConfirmation_and_logoutCalledOnConfirm() {
        // given
        let logoutService = MockLogoutService()
        let presenter = ProfilePresenter(
            profileService: MockProfileService(),
            imageService: MockImageService(),
            logoutService: logoutService
        )
        let view = MockProfileView()
        presenter.view = view

        // when
        presenter.didTapLogoutButton()

        // then
        XCTAssertTrue(view.didShowLogoutConfirmation)
        XCTAssertNotNil(view.lastConfirmAction)

       
        view.lastConfirmAction?()
        XCTAssertTrue(logoutService.didLogout)
    }
}
