import UIKit

// MARK: AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

// MARK: AuthViewController

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "showWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔹 AuthViewController загружен")
        configureBackButton()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("➡️ Подготовка к переходу с идентификатором: \(segue.identifier ?? "без идентификатора")")
        switch segue.identifier {
        case showWebViewSegueIdentifier:
            prepareWebViewController(for: segue)
        default:
            super.prepare(for: segue, sender: sender)
        }
    }

    private func prepareWebViewController(for segue: UIStoryboardSegue) {
        guard let webViewViewController = segue.destination as? WebViewViewController else {
            assertionFailure("❌ Не удалось подготовить WebViewViewController для \(showWebViewSegueIdentifier)")
            return
        }
        print("ℹ️ WebViewViewController подготовлен")
        webViewViewController.delegate = self
    }
    
    // MARK: Private Methods
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
        print("ℹ️ Назад кнопка настроена")
    }
}

// MARK: WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("🔑 Получен код авторизации: \(code)")
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success(let token):
                print("✅ Успешно получен токен: \(token)")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.didAuthenticate(self)
                }
            case .failure(let error):
                print("❌ Ошибка получения токена: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        print("ℹ️ Отмена авторизации")
        vc.dismiss(animated: true)
    }
}
