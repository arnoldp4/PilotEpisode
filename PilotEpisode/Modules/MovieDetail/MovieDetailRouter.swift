import UIKit

protocol MovieDetailRouterSpecs: AnyObject {
    func navigateToTrailer(url: URL)
}

final class MovieDetailRouter: MovieDetailRouterSpecs {
    private weak var viewController: UIViewController?
    
    static func createModule(movieId: Int, tmdbService: TMDBServiceProtocol = TMDBService()) -> UIViewController {
        let view = MovieDetailViewController()
        let presenter = MovieDetailPresenter(movieId: movieId)
        let interactor = MovieDetailInteractor(tmdbService: tmdbService)
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
        guard let viewController = viewController else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
