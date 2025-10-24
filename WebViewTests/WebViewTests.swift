import XCTest
import UIKit
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    final class WebViewPresenterSpy: WebViewPresenterProtocol {
        var viewDidLoadCalled: Bool = false
        var view: WebViewViewControllerProtocol?
        
        func viewDidLoad() {
            viewDidLoadCalled = true
        }
        
        func didUpdateProgressValue(_ newValue: Double) { }
        
        func code(from url: URL) -> String? { nil }
    }
    
    final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
        var presenter: WebViewPresenterProtocol?
        var loadRequestCalled: Bool = false
        
        func load(request: URLRequest) {
            loadRequestCalled = true
        }
        
        func setProgressValue(_ newValue: Float) { }
        
        func setProgressHidden(_ isHidden: Bool) { }
    }
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
}
