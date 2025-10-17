
import UIKit
import Kingfisher
import SwiftKeychainWrapper


final class ImagesListViewController: UIViewController {
    
    // MARK: Properties
    
    private let segueID = "ShowSingleImage"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    
    // Добавляем токен
    private var token: String? {
        return OAuth2TokenStorage.shared.token // Получаем токен из OAuth2TokenStorage
    }
    
    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        // Подписка на обновления фотографий
        imagesListService.onPhotosUpdated = { [weak self] in
            guard let self = self else { return }
            let oldCount = self.photos.count // Сохраняем старое количество
            self.photos = self.imagesListService.photos // Обновляем массив фотографий
            self.updateTableViewAnimated(oldCount: oldCount, newCount: self.photos.count) // Вызываем анимированное обновление
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangePhotos), name: ImagesListService.didChangeNotification, object: nil)
        
        // Начальная загрузка фотографий
        if let token = token { // Проверяем, существует ли токен
            imagesListService.fetchPhotosNextPage(with: token) // Передаем токен в метод
        } else {
            print("Ошибка: Токен отсутствует") // Обрабатываем случай, когда токен отсутствует
        }
    }
    
    @objc private func didChangePhotos() {
        let oldCount = photos.count
        photos = imagesListService.photos
        updateTableViewAnimated(oldCount: oldCount, newCount: photos.count)
    }
    
    private func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            // Получаем изображение по URL
            viewController.imageURL = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Private Methods
    
    private func addGradientBackground(to label: UILabel, in cell: UITableViewCell) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 0.0).cgColor,
            UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: label.bounds.height)
        
        label.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        
        label.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            fatalError("Unable to dequeue ImagesListCell.")
        }
        
        // Настройка ячейки с помощью Kingfisher
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        
        return cell
    }
}

// MARK: Cell Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row] // Получаем объект Photo
        
        // Устанавливаем заглушку перед загрузкой изображения
        cell.cellImage.image = UIImage(named: "placeholder_image")
        
        // Настройка индикатора загрузки
        cell.cellImage.kf.indicatorType = .activity
        
        // Загрузка изображения с помощью Kingfisher
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = displayDateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        addGradientBackground(to: cell.dateLabel, in: cell)
        
        let isLiked = photo.isLiked // Используем свойство isLiked из объекта Photo
        // Используем метод setIsLiked вместо прямой установки изображения
        cell.setIsLiked(isLiked, animated: false)
    }
}

// MARK: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueID, sender: indexPath)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]
        
        let photoWidth = photo.size.width
        let photoHeight = photo.size.height
        guard photoWidth > 0 && photoHeight > 0 else { return 200 }
        
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - insets.left - insets.right
        
        let scale = imageViewWidth / photoWidth
        return photoHeight * scale + insets.top + insets.bottom
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 { // Если это последняя ячейка
            if let token = token { // Проверяем, существует ли токен
                imagesListService.fetchPhotosNextPage(with: token) // Загружаем следующую страницу
            } else {
                print("Ошибка: Токен отсутствует") // Обрабатываем случай, когда токен отсутствует
            }
        }
    }
}


// MARK: ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let shouldLike = !photo.isLiked
        
    
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: shouldLike) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                   
                    UIBlockingProgressHUD.dismiss()
                    return
                }
                
                switch result {
                case .success:
                  
                    self.photos = self.imagesListService.photos
                    
                    
                    if indexPath.row < self.photos.count {
                        let updatedIsLiked = self.photos[indexPath.row].isLiked
                        if let visibleCell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                            visibleCell.setIsLiked(updatedIsLiked, animated: true)
                        } else {
                            
                            self.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                    
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}





