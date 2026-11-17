struct MovieResponse: Codable {
    let page: Int
    let results: [MovieEntity]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

struct MovieEntity: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
    }
}