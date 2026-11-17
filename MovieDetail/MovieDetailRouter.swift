import UIKit

protocol MovieDetailRouterSpecs {
    func navigateToTrailer(url: URL)
}

class MovieDetailRouter: MovieDetailRouterSpecs {
    weak var viewController: UIViewController?
    
    static func createModule(movieId: Int) -> UIViewController {
        let view = MovieDetailVC()
        let presenter = MovieDetailPresenter(movieId: movieId)
        let interactor = MovieDetailInteractor()
        let router = MovieDetailRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view
        
        return view
    }
    
    func navigateToTrailer(url: URL) {
        UIApplication.shared.open(url)
    }
}