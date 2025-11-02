

import Foundation
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func reloadData()
    func insertRows(at indexPaths: [IndexPath])
    func reloadRow(at indexPath: IndexPath)
    func showError(_ message: String)
    func performShowSingleImage(with url: URL)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewProtocol? { get set }
    func viewDidLoad()
    func numberOfPhotos() -> Int
    func configure(cell: ImagesListCell, at index: Int)
    func didSelectRow(at index: Int)
    func willDisplayRow(at index: Int, tableWidth: CGFloat)
    func didTapLike(at index: Int)
    func formattedDate(at index: Int) -> String
    func heightForRow(at index: Int, tableWidth: CGFloat) -> CGFloat
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    private let service: ImagesListService
    private var photos: [Photo] = []
    private let tokenProvider: () -> String?

    init(service: ImagesListService = ImagesListService(),
         tokenProvider: @escaping () -> String? = { OAuth2TokenStorage.shared.token }) {
        self.service = service
        self.tokenProvider = tokenProvider

        service.onPhotosUpdated = { [weak self] in
            guard let self = self else { return }
            let oldCount = self.photos.count
            self.photos = self.service.photos
            let newCount = self.photos.count

            DispatchQueue.main.async {
                if oldCount != newCount {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    self.view?.insertRows(at: indexPaths)
                } else {
                    self.view?.reloadData()
                }
            }
        }
    }

    func viewDidLoad() {
        loadNextPageIfNeeded()
    }

    func numberOfPhotos() -> Int { photos.count }

    func configure(cell: ImagesListCell, at index: Int) {
        guard photos.indices.contains(index) else { return }
        let photo = photos[index]

        DispatchQueue.main.async {
            cell.cellImage.image = UIImage(named: "placeholder_image")
            cell.cellImage.kf.indicatorType = .activity
            if let url = URL(string: photo.thumbImageURL) {
                cell.cellImage.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                cell.cellImage.image = UIImage(named: "placeholder_image")
            }
            cell.dateLabel.text = ImagesListHelper.formattedDate(photo.createdAt)
            cell.setIsLiked(photo.isLiked, animated: false)
        }
    }

    func didSelectRow(at index: Int) {
        guard photos.indices.contains(index),
              let url = URL(string: photos[index].largeImageURL) else { return }
        view?.performShowSingleImage(with: url)
    }

    func willDisplayRow(at index: Int, tableWidth: CGFloat) {
        if index == photos.count - 1 { loadNextPageIfNeeded() }
    }

    private func loadNextPageIfNeeded() {
        guard let token = tokenProvider() else { return }
        service.fetchPhotosNextPage(with: token)
    }

    func didTapLike(at index: Int) {
        guard photos.indices.contains(index) else { return }
        let photo = photos[index]
        let shouldLike = !photo.isLiked

        UIBlockingProgressHUD.show()

        service.changeLike(photoId: photo.id, isLike: shouldLike) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }

                switch result {
                case .success:
                    self.photos = self.service.photos
                    self.view?.reloadRow(at: IndexPath(row: index, section: 0))
                case .failure(let error):
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }

    func formattedDate(at index: Int) -> String {
        guard photos.indices.contains(index) else { return "" }
        return ImagesListHelper.formattedDate(photos[index].createdAt)
    }

    func heightForRow(at index: Int, tableWidth: CGFloat) -> CGFloat {
        guard photos.indices.contains(index) else { return 0 }
        return ImagesListHelper.cellHeight(for: photos[index], tableWidth: tableWidth)
    }
}
