//
//  TMDBMockService.swift
//  PilotEpisode
//
//  Created by Arnold Pangestu on 18/11/26.
//

import XCTest
@testable import PilotEpisode

final class MockTMDBService: TMDBServiceProtocol {
    // Override the shared singleton instance during tests
    static var sharedMock = MockTMDBService()
    
    var shouldFail = false
    var mockGenres: [GenreEntity] = [GenreEntity(id: 28, name: "Action")]
    var mockMovies: [MovieEntity] = [MovieEntity(id: 101, title: "Action Movie 1", overview: "Overview 1", posterPath: nil)]
    var mockMovieDetail = MovieDetailEntity(id: 101, title: "Action Movie 1", overview: "Detailed Overview 1", posterPath: nil)
    var mockVideos = [VideoEntity(key: "trailer123", site: "YouTube", type: "Trailer")]
    var mockReviews = [ReviewEntity(author: "Reviewer A", content: "Awesome movie!")]

    func fetchGenres(completion: @escaping (Result<[GenreEntity], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch genres"])))
        } else {
            completion(.success(mockGenres))
        }
    }
    
    func discoverMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movies"])))
        } else {
            let response = MovieResponse(page: page, results: mockMovies, totalPages: 2)
            completion(.success(response))
        }
    }
    
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetailEntity, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch movie detail"])))
        } else {
            completion(.success(mockMovieDetail))
        }
    }
    
    func fetchMovieVideos(movieId: Int, completion: @escaping (Result<[VideoEntity], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch videos"])))
        } else {
            completion(.success(mockVideos))
        }
    }
    
    func fetchMovieReviews(movieId: Int, page: Int, completion: @escaping (Result<ReviewResponse, Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch reviews"])))
        } else {
            let response = ReviewResponse(results: mockReviews, totalPages: 1)
            completion(.success(response))
        }
    }
}
