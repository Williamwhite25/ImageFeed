import XCTest
@testable import ImageFeed

final class ImagesListHelperSimpleTests: XCTestCase {

    private func makePhotoResult(createdAt: String? = nil, width: Int = 100, height: Int = 100, thumb: String = "", full: String = "") -> PhotoResult {
        return PhotoResult(
            id: "1",
            createdAt: createdAt,
            width: width,
            height: height,
            color: "#000000",
            blurHash: nil,
            likes: 0,
            likedByUser: false,
            description: nil,
            urls: PhotoResult.UrlsResult(raw: "", full: full, regular: "", small: "", thumb: thumb)
        )
    }

    func testFormattedDate_nilReturnsEmpty() {
        XCTAssertEqual(ImagesListHelper.formattedDate(nil, locale: Locale(identifier: "en_US")), "")
    }

    func testFormattedDate_nonNilReturnsNonEmptyString() {
        
        let createdAt = "2021-12-31T00:00:00Z"
        let pr = makePhotoResult(createdAt: createdAt)
        let photo = Photo(from: pr)
        let result = ImagesListHelper.formattedDate(photo.createdAt, locale: Locale(identifier: "en_US"))
        XCTAssertFalse(result.isEmpty)
    }

    func testCellHeight_zeroSizeReturnsDefault200() {
       
        let pr = makePhotoResult(width: 0, height: 0)
        let photo = Photo(from: pr)
        let height = ImagesListHelper.cellHeight(for: photo, tableWidth: 320)
        XCTAssertEqual(height, 200)
    }
}
