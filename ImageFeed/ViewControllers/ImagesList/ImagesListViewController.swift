

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let segueID = "ShowSingleImage"
    @IBOutlet weak var tableView: UITableView!

    private var presenter: ImagesListPresenterProtocol!

    // MARK: - DI
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if presenter == nil {
            let defaultPresenter = ImagesListPresenter()
            configure(presenter: defaultPresenter)
        }

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        tableView.dataSource = self
        tableView.delegate = self

        presenter.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            guard let vc = segue.destination as? SingleImageViewController, let url = sender as? URL else {
                assertionFailure("Invalid segue destination")
                return
            }
            vc.imageURL = url.absoluteString
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: ImagesListViewProtocol {
    func reloadData() { tableView.reloadData() }

    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func performShowSingleImage(with url: URL) {
        performSegue(withIdentifier: segueID, sender: url)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfPhotos()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            fatalError("Unable to dequeue ImagesListCell.")
        }

        cell.delegate = self
        presenter.configure(cell: cell, at: indexPath.row)
        addGradientBackground(to: cell.dateLabel, in: cell)
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.heightForRow(at: indexPath.row, tableWidth: tableView.bounds.width)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayRow(at: indexPath.row, tableWidth: tableView.bounds.width)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.didTapLike(at: indexPath.row)
    }
}
