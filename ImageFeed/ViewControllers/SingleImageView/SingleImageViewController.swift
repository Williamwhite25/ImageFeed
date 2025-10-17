
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: String?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        if let image = image {
            setupImageView(with: image)
        } else {
            loadImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let image = imageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    private func loadImage() {
        guard let urlString = imageURL, let url = URL(string: urlString) else { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self.setupImageView(with: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func setupImageView(with image: UIImage) {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame.origin = .zero
        
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    @IBAction private func didTapBackButton() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.contentInset = .zero
        scrollView.contentOffset = .zero
        view.layoutIfNeeded()
        
        let visibleSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleSize.width / imageSize.width
        let vScale = visibleSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let contentSize = scrollView.contentSize
        let horizontalInset = max(0, (visibleSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (visibleSize.height - contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
    
    private func showError() {
        let alert = UIAlertController(title: nil,
                                      message: "Что-то пошло не так. Попробовать ещё раз?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.loadImage()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}





