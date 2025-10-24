

import UIKit

enum ImagesListHelper {
    static func formattedDate(_ date: Date?, locale: Locale = .current) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = locale
        return formatter.string(from: date)
    }

    static func cellHeight(for photo: Photo, tableWidth: CGFloat, insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)) -> CGFloat {
        let photoWidth = photo.size.width
        let photoHeight = photo.size.height
        guard photoWidth > 0 && photoHeight > 0 else { return 200 }
        let imageViewWidth = tableWidth - insets.left - insets.right
        let scale = imageViewWidth / photoWidth
        return photoHeight * scale + insets.top + insets.bottom
    }
}
