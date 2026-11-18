import UIKit

protocol MovieListRouterSpecs: AnyObject {
    func navigateToMovieDetail(movieId: Int)
}

final class MovieListRouter: MovieListRouterSpecs {
    private weak var viewController: UIViewController?
    
    static func createModule(genreId: Int, tmdbService: TMDBServiceProtocol = TMDBService()) -> UIViewController {
        let view = MovieListViewController()
        let presenter = MovieListPresenter(genreId: genreId)
        let interactor = MovieListInteractor(tmdbService: tmdbService)
        let router = MovieListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToMovieDetail(movieId: Int) {
        let detailVC = MovieDetailRouter.createModule(movieId: movieId)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }
}
