import Foundation

struct Movie: Identifiable, Codable, Hashable {
    let id: Int
    let title: String?
    let name: String? // TV Shows use "name" instead of "title"
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let firstAirDate: String? // TV Shows use "first_air_date"
    let voteAverage: Double?

    // Handle title display for both Movies & TV Shows
    var displayTitle: String {
        return title ?? name ?? "Unknown Title"
    }

    // Construct full URL for the poster image
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    // Construct full URL for the background image (backdrop)
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name // For TV shows
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date" // For TV shows
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
