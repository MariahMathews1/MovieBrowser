import Foundation

struct Movie: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double

    // Construct full URL for the poster image
    var posterURL: URL? {
        if let path = posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
        return nil
    }

    // Construct full URL for the background image (backdrop)
    var backdropURL: URL? {
        if let path = backdropPath {
            return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }

    // **Conform to Hashable to allow using Set<Movie>**
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}

// **Fix: Add `MovieResponse` Struct to Decode API Response**
struct MovieResponse: Codable {
    let results: [Movie]
}
