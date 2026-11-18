import Foundation

protocol TMDBServiceProtocol {
    func fetchGenres(completion: @escaping (Result<[GenreEntity], Error>) -> Void)
    func discoverMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void)
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetailEntity, Error>) -> Void)
    func fetchMovieVideos(movieId: Int, completion: @escaping (Result<[VideoEntity], Error>) -> Void)
    func fetchMovieReviews(movieId: Int, page: Int, completion: @escaping (Result<ReviewResponse, Error>) -> Void)
}

final class TMDBService: TMDBServiceProtocol {
    
    private let accessToken: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let token = dict["TMDB_ACCESS_TOKEN"] as? String else {
            fatalError("Config.plist or TMDB_ACCESS_TOKEN is missing!")
        }
        return token
    }()
    
    private let baseURL = "https://api.themoviedb.org/3"
    
    // Initializer is public so it can be instantiated and injected where needed (No Singleton!)
    init() {}
    
    private func request<T: Decodable>(endpoint: String, parameters: [String: String] = [:], completion: @escaping (Result<T, Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)\(endpoint)")!
        
        if !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - TMDBServiceProtocol Conformance
extension TMDBService {
    func fetchGenres(completion: @escaping (Result<[GenreEntity], Error>) -> Void) {
        request(endpoint: "/genre/movie/list") { (result: Result<GenreResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.genres))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func discoverMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let params = ["with_genres": "\(genreId)", "page": "\(page)"]
        request(endpoint: "/discover/movie", parameters: params, completion: completion)
    }
    
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetailEntity, Error>) -> Void) {
        request(endpoint: "/movie/\(movieId)", completion: completion)
    }
    
    func fetchMovieVideos(movieId: Int, completion: @escaping (Result<[VideoEntity], Error>) -> Void) {
        request(endpoint: "/movie/\(movieId)/videos") { (result: Result<VideoResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieReviews(movieId: Int, page: Int, completion: @escaping (Result<ReviewResponse, Error>) -> Void) {
        let params = ["page": "\(page)"]
        request(endpoint: "/movie/\(movieId)/reviews", parameters: params, completion: completion)
    }
}
