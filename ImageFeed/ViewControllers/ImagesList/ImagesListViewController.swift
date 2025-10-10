import UIKit

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
            self?.photos = self?.imagesListService.photos ?? []
            self?.tableView.reloadData()
        }
        
        // Начальная загрузка фотографий
        imagesListService.fetchPhotosNextPage()
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
            let image = UIImage(named: photos[indexPath.row].thumbImageURL) // Изменено: используем URL миниатюры
            viewController.image = image
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

// MARK: Cell Configuration

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row] // Получаем объект Photo
        cell.cellImage.image = UIImage(named: photo.thumbImageURL) // Получаем изображение по URL
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
}
