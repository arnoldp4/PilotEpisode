import Foundation

protocol MovieDetailInteractorInputSpecs: AnyObject {
    func fetchMovieDetails(id: Int)
    func fetchReviews(id: Int, page: Int)
    func fetchVideos(id: Int)
}

protocol MovieDetailInteractorOutputSpecs: AnyObject {
    func didFetchMovie(_ movie: MovieDetailEntity)
    func didFetchReviews(_ newReviews: [ReviewEntity], totalPages: Int)
    func didFetchTrailerKey(_ key: String)
    func didFailFetching(error: Error)
}

final class MovieDetailInteractor: MovieDetailInteractorInputSpecs {
    weak var output: MovieDetailInteractorOutputSpecs?
    private let tmdbService: TMDBServiceProtocol
        
    init(tmdbService: TMDBServiceProtocol = TMDBService()) {
        self.tmdbService = tmdbService
    }
    
    func fetchMovieDetails(id: Int) {
        tmdbService.fetchMovieDetails(movieId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movie):
                    self?.output?.didFetchMovie(movie)
                case .failure(let error):
                    self?.output?.didFailFetching(error: error)
                }
            }
        }
    }
    
    func fetchReviews(id: Int, page: Int) {
        tmdbService.fetchMovieReviews(movieId: id, page: page) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.output?.didFetchReviews(response.results, totalPages: response.totalPages)
                case .failure(let error):
                    self?.output?.didFailFetching(error: error)
                }
            }
        }
    }

    func fetchVideos(id: Int) {
        tmdbService.fetchMovieVideos(movieId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let videos):
                    let trailer = videos.first { $0.site == "YouTube" && $0.type == "Trailer" } ?? videos.first
                    if let key = trailer?.key {
                        self?.output?.didFetchTrailerKey(key)
                    }
                case .failure:
                    break
                }
            }
        }
    }
}
