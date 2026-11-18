import UIKit

protocol GenreListPresenterSpecs {
    var genresCount: Int { get }
    func viewIsReady()
    func genre(at index: Int) -> GenreEntity
    func didSelectGenre(at index: Int)
}

final class GenreListPresenter: GenreListPresenterSpecs, GenreListInteractorOutputSpecs {
    weak var view: GenreListViewSpecs?
    var interactor: GenreListInteractorInputSpecs?
    var router: GenreListRouterSpecs?
    
    private var genres: [GenreEntity] = []
    
    var genresCount: Int {
        genres.count
    }
    
    func viewIsReady() {
        interactor?.fetchGenres()
    }
    
    func genre(at index: Int) -> GenreEntity {
        genres[index]
    }
    
    func didSelectGenre(at index: Int) {
        let selectedGenre = genres[index]
        router?.navigateToMovieList(genre: selectedGenre)
    }
    
    // MARK: - Interactor Output
    
    func didFetchGenres(_ genres: [GenreEntity]) {
        self.genres = genres
        view?.reloadData()
    }
    
    func didFailFetching(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
