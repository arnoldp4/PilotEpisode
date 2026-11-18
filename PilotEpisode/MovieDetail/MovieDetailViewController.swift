import UIKit
import WebKit

protocol MovieDetailViewSpecs: AnyObject {
    func displayMovie(title: String, overview: String)
    func showError(_ message: String)
    func displayTrailer(key: String)
    func displayReviews(_ reviews: [ReviewEntity])
}

final class MovieDetailVC: UIViewController, MovieDetailViewSpecs, WKNavigationDelegate {
    
    var presenter: MovieDetailPresenterSpecs?
    
    // MARK: - UI Components
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Clean property name: imageView instead of trailerImageView
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Trick YouTube into thinking this is regular Safari, bypassing Error 153/152
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        return webView
    }()
    
    lazy var youtubeFallbackButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Watch Trailer on YouTube", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.isHidden = true // Hidden by default, only shows if embed fails
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openYouTubeExternally), for: .touchUpInside)
        return button
    }()

    lazy var reviewsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var reviews: [ReviewEntity] = []
    private var currentTrailerKey: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        setupView()
        presenter?.viewIsReady()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(webView)
        view.addSubview(reviewsTableView)
        view.addSubview(youtubeFallbackButton) // Add this
        view.addSubview(reviewsTableView)
            
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
            
            // Trailer Thumbnail Card (Zero Error 153s)
            webView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 16),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 200),
            
            // Fallback button centered over the trailer area just in case
            youtubeFallbackButton.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            youtubeFallbackButton.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            youtubeFallbackButton.widthAnchor.constraint(equalToConstant: 220),
            youtubeFallbackButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Reviews TableView fills the rest
            reviewsTableView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 8),
            reviewsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reviewsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            reviewsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func openYouTubeTrailer() {
        guard let key = currentTrailerKey, let url = URL(string: "https://www.youtube.com/watch?v=\(key)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - View Specs Conformance
    
    func displayMovie(title: String, overview: String) {
        titleLabel.text = title
        overviewLabel.text = overview
    }
    
    // Save the key when displaying
    func displayTrailer(key: String) {
        self.currentTrailerKey = key
        // Added /embed/ into the URL path
        guard let url = URL(string: "https://www.youtube-nocookie.com/embed/\(key)?playsinline=1&rel=0") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("https://www.youtube-nocookie.com", forHTTPHeaderField: "Referer")
        
        webView.load(request)
    }

    // Catch if YouTube fails to load or blocks the iframe
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        youtubeFallbackButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        youtubeFallbackButton.isHidden = false
    }

    @objc private func openYouTubeExternally() {
        guard let key = currentTrailerKey, let url = URL(string: "https://www.youtube.com/watch?v=\(key)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func displayReviews(_ reviews: [ReviewEntity]) {
        self.reviews = reviews
        reviewsTableView.reloadData()
        
        if reviews.isEmpty {
            let label = UILabel()
            label.text = "No reviews available."
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            reviewsTableView.backgroundView = label
        } else {
            reviewsTableView.backgroundView = nil
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate

extension MovieDetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        cell.selectionStyle = .none
        let review = reviews[indexPath.row]
        
        // 1. Bold Author Header
        let authorName = review.author.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalString = NSMutableAttributedString(
            string: "\(authorName)\n\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        
        // 2. Render Markdown natively
        let contentString = parseNativeMarkdown(review.content)
        finalString.append(contentString)
        
        // 3. Use a UITextView inside cell.contentView to handle interactive links seamlessly without flash
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
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        
        if let parsed = try? AttributedString(markdown: text, options: options) {
            let mutableAttrString = NSMutableAttributedString(parsed)
            let fullRange = NSRange(location: 0, length: mutableAttrString.length)
            
            // Set body color and enforce a clean 15pt system font across everything
            mutableAttrString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: fullRange)
            mutableAttrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: fullRange)
            
            // If markdown has bold tags, ensure those specific ranges stay bold at 15pt
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
        
        // Fallback if markdown parsing fails
        return NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == reviewsTableView {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height
            if offsetY > (contentHeight - height - 100) {
                (presenter as? MovieDetailPresenter)?.didScrollReviewsToBottom()
            }
        }
    }
}
