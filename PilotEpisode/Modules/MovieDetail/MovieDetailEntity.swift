struct MovieDetailEntity: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
    }
}

// Video Models
struct VideoResponse: Codable {
    let results: [VideoEntity]
}

struct VideoEntity: Codable {
    let key: String
    let site: String
    let type: String
}

// Review Models
struct ReviewResponse: Codable {
    let results: [ReviewEntity]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case results
        case totalPages = "total_pages"
    }
}

struct ReviewEntity: Codable {
    let author: String
    let content: String
}
