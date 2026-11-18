import UIKit

protocol MovieListViewSpecs: AnyObject {
    func reloadData()
    func showError(message: String)
}

final class MovieListViewController: UIViewController {
    
    var presenter: MovieListPresenterSpecs?
    
    // MARK: - Private UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        setupView()
        presenter?.viewIsReady()
    }
}

// MARK: - Setup Views
extension MovieListViewController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - MovieListViewSpecs Conformance
extension MovieListViewController: MovieListViewSpecs {
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            if self.presenter?.moviesCount == 0 {
                let label = UILabel()
                label.text = "No movies found."
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                self.collectionView.backgroundView = label
            } else {
                self.collectionView.backgroundView = nil
            }
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate (Endless Scroll)
extension MovieListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > (contentHeight - height - 200) {
            presenter?.didScrollToBottom()
        }
    }
}

// MARK: - UICollectionView DataSource, Delegate & FlowLayout
extension MovieListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.moviesCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath)
        cell.backgroundColor = .systemGray5
        
        let movie = presenter?.movie(at: indexPath.item)
        
        let imageViewTag = 99
        let imageView: UIImageView
        if let existing = cell.contentView.viewWithTag(imageViewTag) as? UIImageView {
            imageView = existing
        } else {
            imageView = UIImageView(frame: cell.contentView.bounds)
            imageView.tag = imageViewTag
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        }
        
        imageView.image = nil
        if let posterPath = movie?.posterPath {
            let urlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
            if let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.didSelectMovie(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 24) / 2
        return CGSize(width: width, height: width * 1.5)
    }
}
