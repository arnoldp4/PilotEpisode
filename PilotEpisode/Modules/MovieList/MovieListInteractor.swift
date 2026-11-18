import Foundation

protocol MovieListInteractorInputSpecs: AnyObject {
    func fetchMovies(genreId: Int, page: Int)
}

protocol MovieListInteractorOutputSpecs: AnyObject {
    func didFetchMovies(_ movies: [MovieEntity], totalPages: Int)
    func didFailFetching(error: Error)
}

final class MovieListInteractor: MovieListInteractorInputSpecs {
    weak var output: MovieListInteractorOutputSpecs?
    private let tmdbService: TMDBServiceProtocol
        
    init(tmdbService: TMDBServiceProtocol = TMDBService()) {
        self.tmdbService = tmdbService
    }
}

// MARK: - MovieListInteractorInputSpecs Conformance
extension MovieListInteractor {
    func fetchMovies(genreId: Int, page: Int) {
        tmdbService.discoverMovies(genreId: genreId, page: page) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.output?.didFetchMovies(response.results, totalPages: response.totalPages)
                case .failure(let error):
                    self?.output?.didFailFetching(error: error)
                }
            }
        }
    }
}
