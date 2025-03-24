import Foundation

// **Movie Model (Handles Both Movies & TV Shows)**
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
    let runtime: Int? // Movies only
    let genres: [Genre]? // Now stores full genre objects
    let numberOfSeasons: Int? // TV Shows only
    let numberOfEpisodes: Int? // TV Shows only
    let popularity: Double?


    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // ✅ Only hash the movie ID
    }

    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id // ✅ Equality is based on ID
    }
    // **Handle title display for both Movies & TV Shows**
    var displayTitle: String {
        return title ?? name ?? "Unknown Title"
    }
    
    private static let defaultPosterURL = URL(string: "https://www.content.numetro.co.za/ui_images/no_poster.png")

    // **Construct full URL for the poster image**
    var posterURL: URL? {
        if let path = posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w500\(path)") ?? Movie.defaultPosterURL
        }
        return Movie.defaultPosterURL
    }

    // **Construct full URL for the backdrop image**
    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }

    // **Formatted Release Date**
    var formattedReleaseDate: String? {
        let dateString = releaseDate ?? firstAirDate
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateString, let dateObject = inputFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d, yyyy"
            return outputFormatter.string(from: dateObject)
        }
        return nil
    }

    // **Formatted Runtime for Movies**
    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }

    // **Formatted Seasons & Episodes for TV Shows**
    var formattedSeasonsEpisodes: String? {
        guard let seasons = numberOfSeasons, let episodes = numberOfEpisodes else { return nil }
        return "\(seasons) Season\(seasons > 1 ? "s" : "") • \(episodes) Episode\(episodes > 1 ? "s" : "")"
    }

    // **Formatted Genres**
    var genreText: String {
        let genreNames = genres?.map { $0.name } ?? []
        return genreNames.isEmpty ? "Unknown Genre" : genreNames.joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case runtime
        case genres
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case popularity
    }
}

// **Genre Model**
struct Genre: Codable, Hashable {
    let id: Int
    let name: String
}

// **Genre Response Model**
struct GenreResponse: Codable {
    let genres: [Genre]
}

// **Movie & TV API Response Model**
struct MovieResponse: Codable {
    let results: [Movie]
}

// **Supporting Cast Model**
struct CastMember: Identifiable, Codable {
    let id: Int
    let name: String
    let profilePath: String?

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }
}

// **Cast API Response**
struct CastResponse: Codable {
    let cast: [CastMember]
}

struct VideoResponse: Codable {
    let results: [Video]

    struct Video: Codable {
        let key: String
        let site: String
        let type: String
    }
}



// **Similar Movies Response**
struct SimilarMoviesResponse: Codable {
    let results: [Movie]
}

// **Streaming Platform Model**
struct StreamingPlatform: Identifiable, Codable {
    let id: Int
    let providerName: String
    let logoPath: String?

    var logoURL: URL? {
        guard let path = logoPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case providerName = "provider_name"
        case logoPath = "logo_path"
    }
}

// **Streaming Provider Model**
struct ProviderInfo: Codable {
    let provider_name: String
}

// **Response Model for Watch Providers**
struct ProviderResponse: Codable {
    let results: [String: [ProviderInfo]] // The key represents country codes like "US"
}

// **Streaming API Response**
struct StreamingResponse: Codable {
    let results: StreamingProviders?

    struct StreamingProviders: Codable {
        let us: ProviderList?
    }

    struct ProviderList: Codable {
        let platforms: [StreamingPlatform]

        enum CodingKeys: String, CodingKey {
            case platforms = "flatrate"
        }
    }
}
