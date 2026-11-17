protocol MovieDetailPresenterSpecs {
    func viewIsReady()
    func didTapTrailer()
}

class MovieDetailPresenter: MovieDetailPresenterSpecs, MovieDetailInteractorOutputSpecs {
    weak var view: MovieDetailViewSpecs?
    var interactor: MovieDetailInteractorInputSpecs?
    var router: MovieDetailRouterSpecs?
    
    private let movieId: Int
    
    init(movieId: Int) {
        self.movieId = movieId
    }
    
    func viewIsReady() {
        // Ask interactor to fetch the movie details
        interactor?.fetchMovieDetails(id: movieId)
    }
    
    func didTapTrailer() {
        // Trigger router navigation
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