import Foundation

protocol MovieListPresenterSpecs: AnyObject {
    var moviesCount: Int { get }
    func viewIsReady()
    func movie(at index: Int) -> MovieEntity
    func didScrollToBottom()
    func didSelectMovie(at index: Int)
}

final class MovieListPresenter {
    weak var view: MovieListViewSpecs?
    var interactor: MovieListInteractorInputSpecs?
    var router: MovieListRouterSpecs?
    
    private let genreId: Int
    private var movies: [MovieEntity] = []
    private var currentPage = 1
    private var totalPages = 1
    private var isLoading = false
    
    init(genreId: Int) {
        self.genreId = genreId
    }
    
    private func loadMoreMovies() {
        isLoading = true
        interactor?.fetchMovies(genreId: genreId, page: currentPage)
    }
}

// MARK: - MovieListPresenterSpecs Conformance
extension MovieListPresenter: MovieListPresenterSpecs {
    var moviesCount: Int {
        movies.count
    }
    
    func viewIsReady() {
        loadMoreMovies()
    }
    
    func movie(at index: Int) -> MovieEntity {
        movies[index]
    }
    
    func didScrollToBottom() {
        guard !isLoading, currentPage < totalPages else { return }
        loadMoreMovies()
    }
    
    func didSelectMovie(at index: Int) {
        let movie = movies[index]
        router?.navigateToMovieDetail(movieId: movie.id)
    }
}

// MARK: - MovieListInteractorOutputSpecs Conformance
extension MovieListPresenter: MovieListInteractorOutputSpecs {
    func didFetchMovies(_ newMovies: [MovieEntity], totalPages: Int) {
        isLoading = false
        self.totalPages = totalPages
        self.movies.append(contentsOf: newMovies)
        self.currentPage += 1
        view?.reloadData()
    }
    
    func didFailFetching(error: Error) {
        isLoading = false
        view?.showError(message: error.localizedDescription)
    }
}
