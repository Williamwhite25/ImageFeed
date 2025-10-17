
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.addTarget(self, action: #selector(likeButtonClicked(_:)), for: .touchUpInside)
    }
    
    @objc private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
    }
    
    func setIsLiked(_ isLiked: Bool, animated: Bool = true) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        let image = UIImage(named: imageName)
        DispatchQueue.main.async {
            if animated {
                UIView.transition(with: self.likeButton, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.likeButton.setImage(image, for: .normal)
                }, completion: nil)
            } else {
                self.likeButton.setImage(image, for: .normal)
            }
        }
    }
}










