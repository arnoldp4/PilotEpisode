import UIKit
import WebKit

protocol MovieDetailViewSpecs: AnyObject {
    func displayMovie(title: String, overview: String)
    func showError(_ message: String)
    func displayTrailer(key: String)
    func displayReviews(_ reviews: [ReviewEntity])
}

final class MovieDetailViewController: UIViewController {
    
    var presenter: MovieDetailPresenterSpecs?
    
    // MARK: - Private UI Components (Private Lazy Var)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        return webView
    }()
    
    private lazy var youtubeFallbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Watch Trailer on YouTube", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFallbackButton), for: .touchUpInside)
        return button
    }()

    private lazy var reviewsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var reviews: [ReviewEntity] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        setupView()
        presenter?.viewIsReady()
    }
    
    @objc private func didTapFallbackButton() {
        presenter?.didTapTrailer()
    }
}

// MARK: - Setup Views
extension MovieDetailViewController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(webView)
        view.addSubview(reviewsTableView)
        view.addSubview(youtubeFallbackButton)
            
        webView.navigationDelegate = self
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        reviewsTableView.allowsSelection = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            webView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 200),
            
            youtubeFallbackButton.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            youtubeFallbackButton.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            youtubeFallbackButton.widthAnchor.constraint(equalToConstant: 220),
            youtubeFallbackButton.heightAnchor.constraint(equalToConstant: 44),
            
            reviewsTableView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 8),
            reviewsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reviewsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            reviewsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - MovieDetailViewSpecs Conformance
extension MovieDetailViewController: MovieDetailViewSpecs {
    func displayMovie(title: String, overview: String) {
        titleLabel.text = title
        overviewLabel.text = overview
    }
    
    func displayTrailer(key: String) {
        guard let url = URL(string: "https://www.youtube-nocookie.com/embed/\(key)?playsinline=1&rel=0") else { return }
        var request = URLRequest(url: url)
        request.setValue("https://www.youtube-nocookie.com", forHTTPHeaderField: "Referer")
        webView.load(request)
    }

    func displayReviews(_ reviews: [ReviewEntity]) {
        self.reviews = reviews
        reviewsTableView.reloadData()
        reviewsTableView.backgroundView = reviews.isEmpty ? createEmptyReviewLabel() : nil
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func createEmptyReviewLabel() -> UILabel {
        let label = UILabel()
        label.text = "No reviews available."
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }
}

// MARK: - WKNavigationDelegate
extension MovieDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        youtubeFallbackButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        youtubeFallbackButton.isHidden = false
    }
}

// MARK: - UITableView DataSource & Delegate
extension MovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        cell.selectionStyle = .none
        let review = reviews[indexPath.row]
        
        let authorName = review.author.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalString = NSMutableAttributedString(
            string: "\(authorName)\n\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        
        finalString.append(parseNativeMarkdown(review.content))
        
        let textViewTag = 99
        let textView: UITextView
        
        if let existingTextView = cell.contentView.viewWithTag(textViewTag) as? UITextView {
            textView = existingTextView
        } else {
            textView = UITextView()
            textView.tag = textViewTag
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.isUserInteractionEnabled = true
            textView.backgroundColor = UIColor.clear
            textView.textContainerInset = UIEdgeInsets.zero
            textView.textContainer.lineFragmentPadding = 0
            textView.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(textView)
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
                textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12),
                textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
            ])
        }
        
        textView.attributedText = finalString
        return cell
    }

    private func parseNativeMarkdown(_ text: String) -> NSAttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        
        if let parsed = try? AttributedString(markdown: text, options: options) {
            let mutableAttrString = NSMutableAttributedString(parsed)
            let fullRange = NSRange(location: 0, length: mutableAttrString.length)
            
            mutableAttrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: fullRange)
            mutableAttrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: fullRange)
            
            mutableAttrString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
                if let existingFont = value as? UIFont,
                   let descriptor = existingFont.fontDescriptor.withDesign(.default) {
                    let isBold = descriptor.symbolicTraits.contains(.traitBold)
                    let isItalic = descriptor.symbolicTraits.contains(.traitItalic)
                    
                    var traits: UIFontDescriptor.SymbolicTraits = []
                    if isBold { traits.insert(.traitBold) }
                    if isItalic { traits.insert(.traitItalic) }
                    
                    if let updatedDescriptor = descriptor.withSymbolicTraits(traits) {
                        let sizedFont = UIFont(descriptor: updatedDescriptor, size: 15)
                        mutableAttrString.addAttribute(.font, value: sizedFont, range: range)
                    }
                }
            }
            return mutableAttrString
        }
        
        return NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular), .foregroundColor: UIColor.secondaryLabel])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == reviewsTableView {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            if offsetY > (contentHeight - height - 100) {
                presenter?.didScrollReviewsToBottom()
            }
        }
    }
}
