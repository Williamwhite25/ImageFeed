import XCTest
@testable import ImageFeed

final class ImagesListHelperTests: XCTestCase {

    func testFormattedDate_nilReturnsEmpty() {
        XCTAssertEqual(ImagesListHelper.formattedDate(nil, locale: Locale(identifier: "en_US")), "")
    }

    func testFormattedDate_nonNilReturnsString() {
        var comps = DateComponents()
        comps.year = 2020; comps.month = 5; comps.day = 4
        let date = Calendar(identifier: .gregorian).date(from: comps)!
        let result = ImagesListHelper.formattedDate(date, locale: Locale(identifier: "en_US"))
        XCTAssertFalse(result.isEmpty)
    }
}
