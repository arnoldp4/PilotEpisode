struct GenreResponse: Codable {
    let genres: [GenreEntity]
}

struct GenreEntity: Codable {
    let id: Int
    let name: String
}