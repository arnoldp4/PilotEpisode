import UIKit

protocol MovieListInteractorInputSpecs {
    func fetchMovies(genreId: Int, page: Int)
}

protocol MovieListInteractorOutputSpecs: AnyObject {
    func didFetchMovies(_ movies: [MovieEntity], totalPages: Int)
    func didFailFetching(error: Error)
}

class MovieListInteractor: MovieListInteractorInputSpecs {
    weak var output: MovieListInteractorOutputSpecs?
    private let tmdbService: TMDBServiceProtocol
        
    init(service: TMDBServiceProtocol = TMDBService.shared) {
        self.tmdbService = service
    }
    
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
