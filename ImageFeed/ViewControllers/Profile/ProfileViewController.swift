import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: UI Elements
    private var avatarImageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var logoutButton = UIButton()

    // MARK: Presenter
    private var presenter: ProfilePresenterProtocol?
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    // MARK: Observer (fallback to old service-driven updates)
    
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypBlack")

        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()

        
        presenter?.viewDidLoad()

        avatarImageView.image = ProfileHelper.placeholderAvatar()
        nameLabel.text = ProfileHelper.defaultName
        loginNameLabel.text = ProfileHelper.defaultLogin
        descriptionLabel.text = ProfileHelper.defaultBio

        if presenter == nil {
            if let profile = ProfileService.shared.profile {
                updateProfileDetails(profile: profile)
            } else {
                print("Ошибка: Профиль не найден.")
            }

            profileImageServiceObserver = NotificationCenter.default.addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }

            updateAvatar()
        }
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: Setup UI
    private func setupAvatarImageView() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupNameLabel() {
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.accessibilityIdentifier = "profile_name_label"
        nameLabel.accessibilityLabel = "Name Lastname"
        
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20)
        ])
    }

    private func setupLoginNameLabel() {
        loginNameLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.accessibilityIdentifier = "profile_login_label"
        loginNameLabel.accessibilityLabel = "@username"
        
        
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }


    private func setupDescriptionLabel() {
        descriptionLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    private func setupLogoutButton() {
        guard let logoutImage = UIImage(systemName: "ipad.and.arrow.forward") else {
            print("Не удалось создать изображение для кнопки выхода")
            return
        }
        
        logoutButton = UIButton.systemButton(
            with: logoutImage,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        
        logoutButton.accessibilityIdentifier = "logout button"
        
        logoutButton.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -36),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    // MARK: Old-style Update Profile Details (fallback)
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? ProfileHelper.defaultName : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? ProfileHelper.defaultLogin : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? ProfileHelper.defaultBio : profile.bio
    }

    // MARK: Old-style Update Avatar (fallback)
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                switch result {
                case .success(let value):
                    print("Изображение загружено: \(value.image)")
                    print("Источник: \(value.cacheType)")
                case .failure(let error):
                    print("Ошибка загрузки изображения: \(error.localizedDescription)")
                }
            }
    }

    // MARK: Actions
    @objc
    private func didTapLogoutButton() {
      
        if let presenter = presenter {
            presenter.didTapLogoutButton()
            return
        }

        let alert = UIAlertController(
            title: "Выйти из аккаунта?",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        present(alert, animated: true)
    }
}

// MARK: - ProfileViewProtocol
extension ProfileViewController: ProfileViewProtocol {
    func displayName(_ name: String) {
        nameLabel.text = name
    }

    func displayLogin(_ login: String) {
        loginNameLabel.text = login
    }

    func displayBio(_ bio: String) {
        descriptionLabel.text = bio
    }

    func displayAvatar(url: URL?) {
        let placeholder = ProfileHelper.placeholderAvatar()
        avatarImageView.kf.indicatorType = .activity

        guard let url = url else {
            avatarImageView.kf.cancelDownloadTask()
            avatarImageView.image = placeholder
            return
        }

        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success: break
                case .failure(let error):
                    print("Ошибка загрузки аватара: \(error.localizedDescription)")
                    self.avatarImageView.image = placeholder
                }
            }
    }

    func showLogoutConfirmation(title: String, message: String, confirmAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            confirmAction()
        })
        present(alert, animated: true)
    }
}
