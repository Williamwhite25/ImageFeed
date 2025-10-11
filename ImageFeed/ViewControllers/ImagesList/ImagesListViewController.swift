
import UIKit
import Kingfisher 

final class ImagesListViewController: UIViewController {
    
    // MARK: Properties
    
    private let segueID = "ShowSingleImage"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
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
        imagesListService.fetchPhotosNextPage()
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
            
            viewController.imageURL = photos[indexPath.row].largeImageURL    } else {
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
        configCell(for: cell, with: indexPath)
        
        return cell
    }
}

// MARK: Cell Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row] // Получаем объект Photo
        
        // Устанавливаем заглушку перед загрузкой изображения
        cell.cellImage.image = UIImage(named: "placeholder_image") // Замените "placeholder_image" на имя вашей заглушки
        
        // Настройка индикатора загрузки
        cell.cellImage.kf.indicatorType = .activity
        
        // Загрузка изображения с помощью Kingfisher
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        addGradientBackground(to: cell.dateLabel, in: cell)
        
        let isLiked = photo.isLiked // Используем свойство isLiked из объекта Photo
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
}

// MARK: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueID, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photos[indexPath.row].thumbImageURL) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 { // Если это последняя ячейка
            imagesListService.fetchPhotosNextPage() // Загружаем следующую страницу
        }
    }
}

// MARK: ImagesListCell

extension ImagesListCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем текущую задачу на загрузку изображения
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil // Очищаем изображение
    }
}




//import UIKit
//import Kingfisher
//
//final class ImagesListViewController: UIViewController {
//    
//    // MARK: Properties
//    
//    private let segueID = "ShowSingleImage"
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    private var photos: [Photo] = []
//    private let imagesListService = ImagesListService()
//    
//    private lazy var dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .long
//        formatter.timeStyle = .none
//        return formatter
//    }()
//    
//    // MARK: Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.rowHeight = 200
//        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
//        
//        // Подписка на обновления фотографий
//        imagesListService.onPhotosUpdated = { [weak self] in
//            guard let self = self else { return }
//            let oldCount = self.photos.count // Сохраняем старое количество
//            self.photos = self.imagesListService.photos // Обновляем массив фотографий
//            self.updateTableViewAnimated(oldCount: oldCount, newCount: self.photos.count) // Вызываем анимированное обновление
//        }
//        
//        // Начальная загрузка фотографий
//        imagesListService.fetchPhotosNextPage()
//    }
//    
//    private func updateTableViewAnimated(oldCount: Int, newCount: Int) {
//        if oldCount != newCount {
//            tableView.performBatchUpdates {
//                let indexPaths = (oldCount..<newCount).map { i in
//                    IndexPath(row: i, section: 0)
//                }
//                tableView.insertRows(at: indexPaths, with: .automatic)
//            } completion: { _ in }
//        }
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == segueID {
//            guard
//                let viewController = segue.destination as? SingleImageViewController,
//                let indexPath = sender as? IndexPath
//            else {
//                assertionFailure("Invalid segue destination")
//                return
//            }
//            
//            // Получаем изображение по URL
//            let image = UIImage(named: photos[indexPath.row].thumbImageURL) // Изменено: используем URL миниатюры
//            viewController.image = image
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    // MARK: Private Methods
//    
//    private func addGradientBackground(to label: UILabel, in cell: UITableViewCell) {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 0.0).cgColor,
//            UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0).cgColor
//        ]
//        
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
//        
//        gradientLayer.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: label.bounds.height)
//        
//        label.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
//        
//        label.layer.insertSublayer(gradientLayer, at: 0)
//    }
//}
//
//// MARK: UITableViewDataSource
//
//extension ImagesListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return photos.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
//        
//        guard let imageListCell = cell as? ImagesListCell else {
//            return UITableViewCell()
//        }
//        
//        configCell(for: imageListCell, with: indexPath)
//        
//        return imageListCell
//    }
//}
//
//// MARK: Cell Configuration
//
//extension ImagesListViewController {
//    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
//        let photo = photos[indexPath.row] // Получаем объект Photo
//        cell.cellImage.image = UIImage(named: photo.thumbImageURL) // Получаем изображение по URL
//        cell.dateLabel.text = dateFormatter.string(from: Date())
//        
//        addGradientBackground(to: cell.dateLabel, in: cell)
//        
//        let isLiked = photo.isLiked // Используем свойство isLiked из объекта Photo
//        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
//        cell.likeButton.setImage(likeImage, for: .normal)
//    }
//}
//
//// MARK: UITableViewDelegate
//
//extension ImagesListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: segueID, sender: indexPath)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let image = UIImage(named: photos[indexPath.row].thumbImageURL) else {
//            return 0
//        }
//        
//        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
//        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
//        let imageWidth = image.size.width
//        let scale = imageViewWidth / imageWidth
//        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
//        return cellHeight
//    }
//}
