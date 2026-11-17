import UIKit

protocol GenreListRouterSpecs {
    func navigateToMovieList(genre: GenreEntity)
}

final class GenreListRouter: GenreListRouterSpecs {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let view = GenreListVC()
        let presenter = GenreListPresenter()
        let interactor = GenreListInteractor()
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