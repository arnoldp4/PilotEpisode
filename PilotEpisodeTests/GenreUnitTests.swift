//
//  GenreUnitTests.swift
//  PilotEpisode
//
//  Created by Arnold Pangestu on 18/11/26.
//

import XCTest
@testable import PilotEpisode

final class MockGenreListView: GenreListViewSpecs {
    var isReloadDataCalled = false
    var errorMessage: String?
    
    func reloadData() {
        isReloadDataCalled = true
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
}

final class MockGenreListInteractor: GenreListInteractorInputSpecs {
    weak var output: GenreListInteractorOutputSpecs?
    var shouldFail = false
    var fetchGenresCallCount = 0
    
    func fetchGenres() {
        fetchGenresCallCount += 1
        if shouldFail {
            output?.didFailFetching(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch genres"]))
        } else {
            output?.didFetchGenres([GenreEntity(id: 28, name: "Action"), GenreEntity(id: 35, name: "Comedy")])
        }
    }
}

final class GenreListUnitTests: XCTestCase {
    private var presenter: GenreListPresenter?
    private var mockInteractor: MockGenreListInteractor?
    private var mockView: MockGenreListView?
    
    override func setUp() {
        super.setUp()
        let view = MockGenreListView()
        let interactor = MockGenreListInteractor()
        let newPresenter = GenreListPresenter()
        
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
    
    func testViewIsReady_Success_ReloadsData() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test setup failed")
            return
        }
        
        mockInteractor.shouldFail = false
        presenter.viewIsReady()
        
        let expectation = XCTestExpectation(description: "Wait for genres fetch")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockView.isReloadDataCalled)
        XCTAssertEqual(presenter.genresCount, 2)
        XCTAssertEqual(presenter.genre(at: 0).name, "Action")
        XCTAssertNil(mockView.errorMessage)
    }
    
    func testViewIsReady_Failure_ShowsError() {
        guard let mockInteractor = mockInteractor,
              let mockView = mockView,
              let presenter = presenter else {
            XCTFail("Test setup failed")
            return
        }
        
        mockInteractor.shouldFail = true
        presenter.viewIsReady()
        
        let expectation = XCTestExpectation(description: "Wait for genre failure")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNotNil(mockView.errorMessage)
        XCTAssertEqual(mockView.errorMessage, "Failed to fetch genres")
    }
    
    func testInit_DoesNotTriggerAnyCalls() {
        XCTAssertEqual(mockInteractor?.fetchGenresCallCount, 0, "Interactor should do nothing upon init before viewIsReady")
    }
}
