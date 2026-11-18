//
//  MovieListUnitTests.swift
//  PilotEpisode
//
//  Created by Arnold Pangestu on 18/11/26.
//

import XCTest
@testable import PilotEpisode

final class MockMovieListView: MovieListViewSpecs {
    var isReloadDataCalled = false
    var errorMessage: String?
    
    func reloadData() {
        isReloadDataCalled = true
    }
    
    func showError(message: String) {
        errorMessage = message
    }
}

final class MockMovieListInteractor: MovieListInteractorInputSpecs {
    weak var output: MovieListInteractorOutputSpecs?
    var shouldFail = false
    var fetchMoviesCallCount = 0
    
    func fetchMovies(genreId: Int, page: Int) {
        fetchMoviesCallCount += 1
        if shouldFail {
            output?.didFailFetching(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movies"]))
        } else {
            let mockMovies = [
                MovieEntity(id: 101, title: "Action Movie 1", overview: "Overview 1", posterPath: nil),
                MovieEntity(id: 102, title: "Action Movie 2", overview: "Overview 2", posterPath: nil)
            ]
            
            output?.didFetchMovies(mockMovies, totalPages: 3)
        }
    }
}

final class MovieListUnitTests: XCTestCase {
    private var presenter: MovieListPresenter?
    private var mockInteractor: MockMovieListInteractor?
    private var mockView: MockMovieListView?
    
    override func setUp() {
        super.setUp()
        let view = MockMovieListView()
        let interactor = MockMovieListInteractor()
        let newPresenter = MovieListPresenter(genreId: 28)
        
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
    
    func testViewIsReady_Success_LoadsMoviesAndPagination() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test setup failed")
            return
        }
        
        mockInteractor.shouldFail = false
        presenter.viewIsReady()
        
        XCTAssertTrue(mockView.isReloadDataCalled)
        XCTAssertEqual(presenter.moviesCount, 2)
        XCTAssertEqual(presenter.movie(at: 0).title, "Action Movie 1")
        XCTAssertNil(mockView.errorMessage)
    }
    
    func testViewIsReady_Failure_StopsLoading() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test setup failed")
            return
        }
        
        mockInteractor.shouldFail = true
        presenter.viewIsReady()
        
        XCTAssertFalse(mockView.isReloadDataCalled)
    }
    
    func testInit_DoesNotTriggerAnyCalls() {
        XCTAssertEqual(mockInteractor?.fetchMoviesCallCount, 0, "SUT should not make any calls upon initialization")
    }

    func testDidScrollToBottom_TriggersSecondFetch() {
        guard let mockInteractor = mockInteractor,
              let presenter = presenter else { return }
        
        presenter.viewIsReady() // First fetch (page 1)
        XCTAssertEqual(mockInteractor.fetchMoviesCallCount, 1)
        
        presenter.didScrollToBottom() // Second fetch (page 2)
        XCTAssertEqual(mockInteractor.fetchMoviesCallCount, 2, "Pagination should trigger a subsequent call to the interactor")
    }
}
