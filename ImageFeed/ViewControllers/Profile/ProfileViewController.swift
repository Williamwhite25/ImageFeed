
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: UI Elements
    private var avatarImageView = UIImageView()
    private var nameLabel = UILabel()
    private var loginNameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var logoutButton = UIButton()
    
    // MARK: Observer
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.1059, green: 0.1098, blue: 0.1373, alpha: 1.0)
        
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        
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
            guard let self = self else { return }
            self.updateAvatar()
        }
        
        updateAvatar()
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
        
        logoutButton.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: Update Profile Details
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }
    
    // MARK: Update Avatar
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
     
    }
}





