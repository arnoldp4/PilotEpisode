import Foundation

protocol GenreListPresenterSpecs: AnyObject {
    var genresCount: Int { get }
    func viewIsReady()
    func genre(at index: Int) -> GenreEntity
    func didSelectGenre(at index: Int)
}

final class GenreListPresenter {
    weak var view: GenreListViewSpecs?
    var interactor: GenreListInteractorInputSpecs?
    var router: GenreListRouterSpecs?
    
    private var genres: [GenreEntity] = []
}

// MARK: - GenreListPresenterSpecs Conformance
extension GenreListPresenter: GenreListPresenterSpecs {
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
}

// MARK: - GenreListInteractorOutputSpecs Conformance
extension GenreListPresenter: GenreListInteractorOutputSpecs {
    func didFetchGenres(_ genres: [GenreEntity]) {
        self.genres = genres
        view?.reloadData()
    }
    
    func didFailFetching(error: Error) {
        view?.showError(error.localizedDescription)
    }
}
