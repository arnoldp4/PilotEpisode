import UIKit

protocol GenreListRouterSpecs: AnyObject {
    func navigateToMovieList(genre: GenreEntity)
}

final class GenreListRouter: GenreListRouterSpecs {
    private weak var viewController: UIViewController?
    
    static func createModule(tmdbService: TMDBServiceProtocol = TMDBService()) -> UIViewController {
        let view = GenreListViewController()
        let presenter = GenreListPresenter()
        let interactor = GenreListInteractor(tmdbService: tmdbService)
        let router = GenreListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToMovieList(genre: GenreEntity) {
        let movieListVC = MovieListRouter.createModule(genreId: genre.id)
        viewController?.navigationController?.pushViewController(movieListVC, animated: true)
    }
}
