import UIKit

protocol MovieDetailPresenterSpecs {
    func viewIsReady()
    func didTapTrailer()
}

class MovieDetailPresenter: MovieDetailPresenterSpecs, MovieDetailInteractorOutputSpecs {
    weak var view: MovieDetailViewSpecs?
    var interactor: MovieDetailInteractorInputSpecs?
    var router: MovieDetailRouterSpecs?
    
    private let movieId: Int
    private var reviews: [ReviewEntity] = []
    private var currentReviewPage = 1
    private var totalReviewPages = 1
    private var isLoadingReviews = false
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    func viewIsReady() {
        interactor?.fetchMovieDetails(id: movieId)
        interactor?.fetchVideos(id: movieId)
        loadMoreReviews()
    }
    
    func didTapTrailer() {
        // Trigger router navigation
    }
    
    func didScrollReviewsToBottom() {
        guard !isLoadingReviews, currentReviewPage <= totalReviewPages else { return }
        loadMoreReviews()
    }

    private func loadMoreReviews() {
        isLoadingReviews = true
        interactor?.fetchReviews(id: movieId, page: currentReviewPage)
    }

    // Add to Interactor Output conformance:
    func didFetchReviews(_ newReviews: [ReviewEntity], totalPages: Int) {
        isLoadingReviews = false
        self.totalReviewPages = totalPages
        self.reviews.append(contentsOf: newReviews)
        self.currentReviewPage += 1
        view?.displayReviews(reviews)
    }

    func didFetchTrailerKey(_ key: String) {
        view?.displayTrailer(key: key)
    }
    
    // MARK: - Interactor Outputs
    
    func didFetchMovie(_ movie: MovieDetailEntity) {
        // Format or process data if needed, then tell the View to display it
        view?.displayMovie(title: movie.title, overview: movie.overview)
    }
    
    func didFailFetching(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
