import UIKit

protocol GenreListInteractorInputSpecs {
    func fetchGenres()
}

protocol GenreListInteractorOutputSpecs: AnyObject {
    func didFetchGenres(_ genres: [GenreEntity])
    func didFailFetching(error: Error)
}

final class GenreListInteractor: GenreListInteractorInputSpecs {
    weak var output: GenreListInteractorOutputSpecs?
    private let tmdbService: TMDBServiceProtocol
        
    init(service: TMDBServiceProtocol = TMDBService.shared) {
        self.tmdbService = service
    }
    
    func fetchGenres() {
        tmdbService.fetchGenres { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let genres):
                    self?.output?.didFetchGenres(genres)
                case .failure(let error):
                    self?.output?.didFailFetching(error: error)
                }
            }
        }
    }
}
