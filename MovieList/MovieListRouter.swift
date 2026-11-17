import UIKit

protocol MovieListRouterSpecs {
    func navigateToMovieDetail(movieId: Int)
}

class MovieListRouter: MovieListRouterSpecs {
    weak var viewController: UIViewController?
    
    static func createModule(genreId: Int) -> UIViewController {
        let view = MovieListVC()
        let presenter = MovieListPresenter(genreId: genreId)
        let interactor = MovieListInteractor()
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