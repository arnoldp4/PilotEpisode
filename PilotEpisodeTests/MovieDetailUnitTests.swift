//
//  MovieDetailUnitTests.swift
//  PilotEpisode
//
//  Created by Arnold Pangestu on 18/11/26.
//

import XCTest
@testable import PilotEpisode

final class MockMovieDetailView: MovieDetailViewSpecs {
    var displayedTitle: String?
    var displayedOverview: String?
    var displayedTrailerKey: String?
    var displayedReviews: [ReviewEntity]?
    var errorMessage: String?
    
    func displayMovie(title: String, overview: String) {
        displayedTitle = title
        displayedOverview = overview
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
    
    func displayTrailer(key: String) {
        displayedTrailerKey = key
    }
    
    func displayReviews(_ reviews: [ReviewEntity]) {
        displayedReviews = reviews
    }
}

final class MockMovieDetailInteractor: MovieDetailInteractorInputSpecs {
    weak var output: MovieDetailInteractorOutputSpecs?
    var shouldFail = false
    
    func fetchMovieDetails(id: Int) {
        if shouldFail {
            output?.didFailFetching(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error"]))
        } else {
            output?.didFetchMovie(MovieDetailEntity(id: id, title: "Action Movie 1", overview: "Detailed Overview 1", posterPath: nil))
        }
    }
    
    func fetchReviews(id: Int, page: Int) {
        if !shouldFail {
            output?.didFetchReviews([ReviewEntity(author: "Reviewer A", content: "Awesome movie!")], totalPages: 1)
        }
    }
    
    func fetchVideos(id: Int) {
        if !shouldFail {
            output?.didFetchTrailerKey("trailer123")
        }
    }
}

final class MovieDetailUnitTests: XCTestCase {
    
    private var presenter: MovieDetailPresenter?
    private var mockInteractor: MockMovieDetailInteractor?
    private var mockView: MockMovieDetailView?
    
    override func setUp() {
        super.setUp()
        let view = MockMovieDetailView()
        let interactor = MockMovieDetailInteractor()
        let newPresenter = MovieDetailPresenter(movieId: 101)
        
        newPresenter.view = view
        newPresenter.interactor = interactor
        interactor.output = newPresenter
        
        mockView = view
        mockInteractor = interactor
        presenter = newPresenter
    }
    
    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        mockView = nil
        super.tearDown()
    }
    
    func testViewIsReady_Success_DisplaysDetailsAndReviews() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockInteractor.shouldFail = false
        presenter.viewIsReady()
        
        let expectation = XCTestExpectation(description: "Wait for movie details & reviews fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(mockView.displayedTitle, "Action Movie 1")
        XCTAssertEqual(mockView.displayedOverview, "Detailed Overview 1")
        XCTAssertEqual(mockView.displayedTrailerKey, "trailer123")
        XCTAssertEqual(mockView.displayedReviews?.count, 1)
        XCTAssertNil(mockView.errorMessage)
    }
    
    func testViewIsReady_Failure_StopsLoadingOrFails() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test dependencies not initialized")
            return
        }
        
        mockInteractor.shouldFail = true
        presenter.viewIsReady()
        
        let expectation = XCTestExpectation(description: "Wait for failure state")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Verifies failure path handles correctly without crashing
        XCTAssertNil(mockView.displayedTitle)
    }
}
