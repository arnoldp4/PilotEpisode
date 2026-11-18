import Foundation

protocol MovieDetailPresenterSpecs: AnyObject {
    func viewIsReady()
    func didTapTrailer()
    func didScrollReviewsToBottom()
}

final class MovieDetailPresenter {
    weak var view: MovieDetailViewSpecs?
    var interactor: MovieDetailInteractorInputSpecs?
    var router: MovieDetailRouterSpecs?
    
    private let movieId: Int
    private var reviews: [ReviewEntity] = []
    private var currentReviewPage = 1
    private var totalReviewPages = 1
    private var isLoadingReviews = false
    private var currentTrailerKey: String?
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    private func loadMoreReviews() {
        guard !isLoadingReviews, currentReviewPage <= totalReviewPages else { return }
        isLoadingReviews = true
        interactor?.fetchReviews(id: movieId, page: currentReviewPage)
    }
}

// MARK: - MovieDetailPresenterSpecs Conformance
extension MovieDetailPresenter: MovieDetailPresenterSpecs {
    func viewIsReady() {
        interactor?.fetchMovieDetails(id: movieId)
        interactor?.fetchVideos(id: movieId)
        loadMoreReviews()
    }
    
    func didTapTrailer() {
        guard let key = currentTrailerKey, let url = URL(string: "https://www.youtube.com/watch?v=\(key)") else { return }
        router?.navigateToTrailer(url: url)
    }
    
    func didScrollReviewsToBottom() {
        loadMoreReviews()
    }
}

// MARK: - MovieDetailInteractorOutputSpecs Conformance
extension MovieDetailPresenter: MovieDetailInteractorOutputSpecs {
    func didFetchMovie(_ movie: MovieDetailEntity) {
        view?.displayMovie(title: movie.title, overview: movie.overview)
    }
    
    func didFetchTrailerKey(_ key: String) {
        self.currentTrailerKey = key
        view?.displayTrailer(key: key)
    }
    
    func didFetchReviews(_ newReviews: [ReviewEntity], totalPages: Int) {
        isLoadingReviews = false
        self.totalReviewPages = totalPages
        self.reviews.append(contentsOf: newReviews)
        self.currentReviewPage += 1
        view?.displayReviews(reviews)
    }
    
    func didFailFetching(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
