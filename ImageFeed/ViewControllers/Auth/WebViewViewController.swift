
import UIKit
import WebKit

// MARK: WebViewConstants

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: WebViewViewController

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: KVO Observation
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self

        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new],
            changeHandler: { [weak self] _, _ in
                self?.updateProgress()
            })
        
        loadAuthView()
    }
    
    // MARK: Private Methods
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to create URL")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: Actions
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}







//
//import UIKit
//import WebKit
//
//// MARK: WebViewConstants
//
//enum WebViewConstants {
//    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
//}
//
//// MARK: WebViewViewControllerDelegate
//
//protocol WebViewViewControllerDelegate: AnyObject {
//    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
//    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
//}
//
//// MARK: WebViewViewController
//
//final class WebViewViewController: UIViewController {
//    @IBOutlet private var webView: WKWebView!
//    @IBOutlet private var progressView: UIProgressView!
//    
//    weak var delegate: WebViewViewControllerDelegate?
//    
//    // MARK: Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        webView.navigationDelegate = self
//        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
//        
//        loadAuthView()
//    }
//    
//    deinit {
//        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
//    }
//    
//    // MARK: Private Methods
//    
//    private func loadAuthView() {
//        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        urlComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: Constants.accessKey),
//            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
//            URLQueryItem(name: "response_type", value: "code"),
//            URLQueryItem(name: "scope", value: Constants.accessScope)
//        ]
//        
//        guard let url = urlComponents.url else {
//            print("Failed to create URL")
//            return
//        }
//        let request = URLRequest(url: url)
//        webView.load(request)
//    }
//    
//    private func updateProgress() {
//        progressView.progress = Float(webView.estimatedProgress)
//        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
//    }
//    
//    // MARK: Actions
//    
//    @IBAction private func didTapBackButton(_ sender: Any?) {
//        delegate?.webViewViewControllerDidCancel(self)
//    }
//    
//    // MARK: - KVO
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == #keyPath(WKWebView.estimatedProgress) {
//            updateProgress()
//        } else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
//    }
//}
//
//// MARK: WKNavigationDelegate
//
//extension WebViewViewController: WKNavigationDelegate {
//    func webView(
//        _ webView: WKWebView,
//        decidePolicyFor navigationAction: WKNavigationAction,
//        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
//    ) {
//        if let code = code(from: navigationAction) {
//            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
//            decisionHandler(.cancel)
//        } else {
//            decisionHandler(.allow)
//        }
//    }
//    
//    private func code(from navigationAction: WKNavigationAction) -> String? {
//        if
//            let url = navigationAction.request.url,
//            let urlComponents = URLComponents(string: url.absoluteString),
//            urlComponents.path == "/oauth/authorize/native",
//            let items = urlComponents.queryItems,
//            let codeItem = items.first(where: { $0.name == "code" })
//        {
//            return codeItem.value
//        } else {
//            return nil
//        }
//    }
//}
