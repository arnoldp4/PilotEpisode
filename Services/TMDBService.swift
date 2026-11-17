import Foundation

class TMDBService {
    static let shared = TMDBService()
    
    // Paste your TMDB API Read Access Token (Bearer Token) here
    private let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkNTBmMGE3ZmNjOTEyYjBlM2NkNjZmNTg5M2FhYjBmNyIsIm5iZiI6MTc5NDkyMzkwMS42OCwic3ViIjoiNmFmYzVkN2Q5MmM1MTZhMjk4NTlmZjAzIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.t1QEQh-DVthKOn_Ekxyb0-Ayj_EyV8b-tWlzTf1wBgs"
    private let baseURL = "https://api.themoviedb.org/3"
    
    private init() {}
    
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
    
    // 1. Fetch Genres
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
    
    // 2. Discover Movies by Genre (with Pagination)
    func discoverMovies(genreId: Int, page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let params = [
            "with_genres": "\(genreId)",
            "page": "\(page)"
        ]
        request(endpoint: "/discover/movie", parameters: params, completion: completion)
    }
    
    // 3. Fetch Movie Details
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetailEntity, Error>) -> Void) {
        request(endpoint: "/movie/\(movieId)", completion: completion)
    }
}