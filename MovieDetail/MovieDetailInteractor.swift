protocol MovieDetailInteractorInputSpecs {
    func fetchMovieDetails(id: Int)
}

protocol MovieDetailInteractorOutputSpecs: AnyObject {
    func didFetchMovie(_ movie: MovieDetailEntity)
    func didFailFetching(error: Error)
}

class MovieDetailInteractor: MovieDetailInteractorInputSpecs {
    weak var output: MovieDetailInteractorOutputSpecs?
    
    func fetchMovieDetails(id: Int) {
        TMDBService.shared.fetchMovieDetails(movieId: id) { [weak self] result in
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
}