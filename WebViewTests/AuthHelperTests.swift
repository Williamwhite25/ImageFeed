

import XCTest
import UIKit
@testable import ImageFeed

final class AuthHelperTests: XCTestCase {

    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        // when
        guard let url = authHelper.authURL() else {
            XCTFail("authURL() returned nil")
            return
        }
        let urlString = url.absoluteString

        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }

    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()

        // when
        let code = authHelper.code(from: url)

        // then
        XCTAssertEqual(code, "test code")
    }
}
