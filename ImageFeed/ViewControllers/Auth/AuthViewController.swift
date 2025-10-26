import UIKit
import ProgressHUD

// MARK: AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

// MARK: AuthViewController

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    @IBOutlet private weak var authenticateButton: UIButton!
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticateButton.accessibilityIdentifier = "Authenticate"
        
        configureBackButton()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showWebViewSegueIdentifier:
            prepareWebViewController(for: segue)
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func prepareWebViewController(for segue: UIStoryboardSegue) {
        guard let webViewViewController = segue.destination as? WebViewViewController else {
            assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
            return
        }
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.delegate = self
    }
    
    // MARK: Private Methods
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
        navigationItem.backBarButtonItem?.accessibilityIdentifier = "nav back button white"
    }
}

// MARK: WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        vc.dismiss(animated: true)
        
        ProgressHUD.animate()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                print("Получен токен: \(token)")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.didAuthenticate(self)
                }
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.showAuthErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: - Alert Handling

extension AuthViewController {
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
