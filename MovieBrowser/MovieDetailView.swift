import SwiftUI
import WebKit

struct MovieDetailView: View {
    let movie: Movie
    @EnvironmentObject var watchlistManager: WatchlistManager
    @AppStorage("isDarkMode") private var isDarkMode = true

    @State private var detailedMovie: Movie? = nil
    @State private var cast: [CastMember] = []
    @State private var similarMovies: [Movie] = []
    @State private var streamingProviders: [String] = []
    @State private var trailerKey: String? = nil

    let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
    var isTVShow: Bool { movie.firstAirDate != nil }

    var body: some View {
        ScrollView {
            ZStack {
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 380)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .black.opacity(0.9),
                                        .black.opacity(0.6),
                                        .clear,
                                        .clear,
                                        .black.opacity(0.7),
                                        .black
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: UIScreen.main.bounds.width, height: 380)
                    }
                }

                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 160)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .offset(y: 130)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 160, height: 240)
                            .cornerRadius(16)
                            .offset(y: 130)
                    }
                }
            }
            .padding(.bottom, 100)

            VStack(spacing: 16) {
                if let detailedMovie = detailedMovie {
                    Text(detailedMovie.displayTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Info
                    HStack(spacing: 16) {
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text("\(String(format: "%.1f", detailedMovie.voteAverage ?? 0))/10")
                                .foregroundColor(isDarkMode ? .white : .black)
                        }

                        if let releaseDate = detailedMovie.formattedReleaseDate {
                            HStack {
                                Image(systemName: "calendar").foregroundColor(.gray)
                                Text(releaseDate).foregroundColor(.gray)
                            }
                        }
                    }

                    if let runtime = detailedMovie.formattedRuntime {
                        Text("\(runtime) • \(detailedMovie.genreText)")
                            .foregroundColor(isDarkMode ? .white : .black)
                            .font(.subheadline)
                    } else if let seasonInfo = detailedMovie.formattedSeasonsEpisodes {
                        Text("\(seasonInfo) • \(detailedMovie.genreText)")
                            .foregroundColor(isDarkMode ? .white : .black)
                            .font(.subheadline)
                    }

                    // Icons
                    HStack(spacing: 30) {
                        actionButton(
                            imageName: watchlistManager.isLiked(movie) ? "hand.thumbsup.fill" : "hand.thumbsup",
                            label: "Like",
                            color: watchlistManager.isLiked(movie) ? .green : (isDarkMode ? .white : .black),
                            action: { watchlistManager.toggleLike(for: movie) }
                        )

                        actionButton(
                            imageName: watchlistManager.isDisliked(movie) ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                            label: "Dislike",
                            color: watchlistManager.isDisliked(movie) ? .red : (isDarkMode ? .white : .black),
                            action: { watchlistManager.toggleDislike(for: movie) }
                        )

                        actionButton(
                            imageName: watchlistManager.isWatched(movie) ? "eye.fill" : "eye",
                            label: watchlistManager.isWatched(movie) ? "Watched" : "Unwatched",
                            color: isDarkMode ? .white : .black,
                            action: { watchlistManager.toggleWatched(for: movie) }
                        )

                        actionButton(
                            imageName: watchlistManager.isInWatchlist(movie) ? "bookmark.fill" : "bookmark",
                            label: "Watchlist",
                            color: isDarkMode ? .white : .black,
                            action: {
                                if watchlistManager.isInWatchlist(movie) {
                                    watchlistManager.removeFromWatchlist(movie)
                                } else {
                                    watchlistManager.addToWatchlist(movie)
                                }
                            }
                        )
                    }
                    .padding()
                    .background((isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.1)))
                    .cornerRadius(12)

                    // Trailer
                    if let key = trailerKey {
                        Text("🎬 Watch Trailer")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .foregroundColor(isDarkMode ? .white : .black)

                        YouTubePlayerView(videoID: key)
                            .frame(height: 250)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    // Overview
                    Text(detailedMovie.overview)
                        .foregroundColor(isDarkMode ? .white.opacity(0.9) : .black.opacity(0.9))
                        .font(.body)
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        .frame(maxWidth: 400, alignment: .leading)

                    // Cast
                    if !cast.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Cast")
                                .font(.title2)
                                .bold()
                                .foregroundColor(isDarkMode ? .white : .black)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 15) {
                                    ForEach(cast) { actor in
                                        VStack {
                                            if let profileURL = actor.profileURL {
                                                AsyncImage(url: profileURL) { image in
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 70, height: 70)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                                } placeholder: {
                                                    Image(systemName: "person.crop.circle.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 70, height: 70)
                                                        .foregroundColor(.gray.opacity(0.7))
                                                }
                                            } else {
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 70, height: 70)
                                                    .foregroundColor(.gray.opacity(0.7))
                                            }

                                            Text(actor.name)
                                                .font(.caption)
                                                .foregroundColor(isDarkMode ? .white : .black)
                                                .frame(width: 80)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(width: 90)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Similar
                    if !similarMovies.isEmpty {
                        VStack(alignment: .leading) {
                            Text("You May Also Like")
                                .font(.title2)
                                .bold()
                                .foregroundColor(isDarkMode ? .white : .black)
                                .padding(.horizontal)
                                .padding(.top, 40)

                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 15) {
                                    ForEach(similarMovies) { similarMovie in
                                        NavigationLink(destination: MovieDetailView(movie: similarMovie)) {
                                            VStack {
                                                if let posterURL = similarMovie.posterURL {
                                                    AsyncImage(url: posterURL) { image in
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .frame(width: 120, height: 180)
                                                            .cornerRadius(10)
                                                    } placeholder: {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.3))
                                                            .frame(width: 120, height: 180)
                                                            .cornerRadius(10)
                                                    }
                                                }
                                                Text(similarMovie.displayTitle)
                                                    .font(.caption)
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 120)
                                                    .foregroundColor(isDarkMode ? .white : .black)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .onAppear {
                fetchFullDetails()
                fetchCast()
                fetchSimilarMovies()
                fetchStreamingProviders()
                fetchTrailer()
            }
        }
        .background((isDarkMode ? Color.black : Color.white).edgesIgnoringSafeArea(.all))
    }

    // MARK: - Shared Action Button
    func actionButton(imageName: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
    }

    // MARK: - API Calls
    func fetchFullDetails() {
        let baseURL = isTVShow ? "https://api.themoviedb.org/3/tv/\(movie.id)" : "https://api.themoviedb.org/3/movie/\(movie.id)"
        let urlString = "\(baseURL)?api_key=\(apiKey)&append_to_response=genres,runtime"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(Movie.self, from: data) {
                DispatchQueue.main.async { self.detailedMovie = decoded }
            }
        }.resume()
    }

    func fetchCast() {
        let endpoint = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/credits?api_key=\(apiKey)"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(CastResponse.self, from: data) {
                DispatchQueue.main.async { self.cast = decoded.cast }
            }
        }.resume()
    }

    func fetchSimilarMovies() {
        let endpoint = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/similar?api_key=\(apiKey)"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimilarMoviesResponse.self, from: data) {
                DispatchQueue.main.async { self.similarMovies = decoded.results }
            }
        }.resume()
    }

    func fetchStreamingProviders() {
        let endpoint = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/watch/providers?api_key=\(apiKey)"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(ProviderResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.streamingProviders = decoded.results["US"]?.compactMap { $0.provider_name } ?? []
                }
            }
        }.resume()
    }

    func fetchTrailer() {
        let endpoint = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/videos?api_key=\(apiKey)"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(VideoResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.trailerKey = decoded.results.first(where: { $0.site == "YouTube" && $0.type == "Trailer" })?.key
                    }
                } catch {
                    print("❌ Trailer error: \(error)")
                }
            }
        }.resume()
    }
}
