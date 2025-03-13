import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @EnvironmentObject var watchlistManager: WatchlistManager //create watchlistManager for user watchlist

    @State private var detailedMovie: Movie? = nil
    @State private var cast: [CastMember] = []
    @State private var similarMovies: [Movie] = []
    @State private var streamingProviders: [String] = []
    @State private var trailerKey: String? = nil


    @State private var showTrailer = false
    let apiKey = "2cbd04c2dac25629f413b3b7d5feef97" // Ensure API key is correctly set

    var isTVShow: Bool {
        return movie.firstAirDate != nil
    }

    var body: some View {
        ScrollView {
            ZStack {
                // **Backdrop with Gradient Overlay**
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: 380)
                            .clipped()
                            .overlay(
                                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.9), .black.opacity(0.6), .clear, .clear, .black.opacity(0.7), .black.opacity(1.0)]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: UIScreen.main.bounds.width, height: 380)
                    }
                }

                // **Poster Image**
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
            .padding(.bottom, 80)

            VStack(spacing: 12) {
                if let detailedMovie = detailedMovie {
                    // **Title**
                    Text(detailedMovie.displayTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)


            
                    //**Watchlist button** (feel free to change to a plus or some other button)
                    Button(action: {
                        if watchlistManager.isInWatchlist(movie) {
                            watchlistManager.removeFromWatchlist(movie)
                        } else {
                            watchlistManager.addToWatchlist(movie)
                        }
                    }) {
                        Text(watchlistManager.isInWatchlist(movie) ? "Remove from Watchlist" : "Add to Watchlist")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(watchlistManager.isInWatchlist(movie) ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .padding(.horizontal)

                    // **Movie Stats (Ratings, Release Date, Genres, Runtime)**
                    VStack {
                        HStack(spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("\(String(format: "%.1f", detailedMovie.voteAverage ?? 0))/10")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }

                            if let releaseDate = detailedMovie.formattedReleaseDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(releaseDate)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }

                        if let runtime = detailedMovie.formattedRuntime {
                            Text("\(runtime) • \(detailedMovie.genreText)")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        } else if let seasonInfo = detailedMovie.formattedSeasonsEpisodes {
                            Text("\(seasonInfo) • \(detailedMovie.genreText)")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom, 25)

                  
                    // **Watch Trailer Button**
                    if let key = trailerKey {
                        Text("🎬 Watch Trailer")
                            .font(.title2)
                            .bold()
                            .padding(.top, 20)
                            .foregroundColor(.white)

                        YouTubePlayerView(videoID: key) // ✅ Embedded Video
                            .frame(height: 250) // Adjust height as needed
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    // **Expandable Description**
                    Text(detailedMovie.overview)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.body)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: 400, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.bottom, 20)

                    // **Cast Section**
                    if !cast.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Cast")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
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
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                                } placeholder: {
                                                    Image(systemName: "person.crop.circle.fill") // Default System Image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 70, height: 70)
                                                        .foregroundColor(.gray.opacity(0.7)) // Subtle gray color
                                                }
                                            } else {
                                                // Default SF Symbol for missing profile picture
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 70, height: 70)
                                                    .foregroundColor(.gray.opacity(0.7))
                                            }

                                            Text(actor.name)
                                                .font(.caption)
                                                .foregroundColor(.white)
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
                    
                    // **Similar Movies Section**
                    if !similarMovies.isEmpty {
                        VStack(alignment: .leading) {
                            Text("You May Also Like")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top,50)

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
                                                    .foregroundColor(.white)
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
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // **Fetch Full Movie or TV Show Details**
    func fetchFullDetails() {
        let baseURL = isTVShow ? "https://api.themoviedb.org/3/tv/\(movie.id)" : "https://api.themoviedb.org/3/movie/\(movie.id)"
        let urlString = "\(baseURL)?api_key=\(apiKey)&append_to_response=genres,runtime"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let decodedResponse = try? JSONDecoder().decode(Movie.self, from: data) {
                DispatchQueue.main.async {
                    self.detailedMovie = decodedResponse
                }
            }
        }.resume()
    }

    // **Fetch Cast Data**
    func fetchCast() {
        let endpoint = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/credits?api_key=\(apiKey)&language=en-US"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data, let decodedResponse = try? JSONDecoder().decode(CastResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.cast = decodedResponse.cast
                }
            }
        }.resume()
    }

    // **Fetch Similar Movies**
    func fetchSimilarMovies() {
            let baseURL = isTVShow ? "tv" : "movie"
            let urlString = "https://api.themoviedb.org/3/\(baseURL)/\(movie.id)/similar?api_key=\(apiKey)"

            URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
                if let data = data, let decodedResponse = try? JSONDecoder().decode(SimilarMoviesResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.similarMovies = decodedResponse.results
                    }
                }
            }.resume()
        }

    // **Fetch Streaming Providers**
    func fetchStreamingProviders() {
        let baseURL = isTVShow ? "tv" : "movie"
        let urlString = "https://api.themoviedb.org/3/\(baseURL)/\(movie.id)/watch/providers?api_key=\(apiKey)"

        URLSession.shared.dataTask(with: URL(string: urlString)!) { data, _, _ in
            if let data = data, let decodedResponse = try? JSONDecoder().decode(ProviderResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.streamingProviders = decodedResponse.results["US"]?.compactMap { $0.provider_name } ?? []
                }
            }
        }.resume()
    }
    
    func fetchTrailer() {
            let endpoint = isTVShow ? "tv" : "movie"
            let urlString = "https://api.themoviedb.org/3/\(endpoint)/\(movie.id)/videos?api_key=\(apiKey)&language=en-US"

            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(VideoResponse.self, from: data)
                        DispatchQueue.main.async {
                            if let key = decodedResponse.results.first(where: { $0.site == "YouTube" && $0.type == "Trailer" })?.key {
                                self.trailerKey = key
                                print("✅ Correct Trailer Key Found: \(key)")
                            } else {
                                print("❌ No valid YouTube trailer found.")
                            }
                        }
                    } catch {
                        print("❌ JSON Decoding Error: \(error)")
                    }
                } else {
                    print("❌ No data received from API")
                }
            }.resume()
        }


}


import SwiftUI
import WebKit

struct TrailerView: View {
    var trailerKey: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let url = URL(string: "https://www.youtube.com/embed/\(trailerKey)?autoplay=1&playsinline=1") {
                WebView(url: url)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        print("🔗 Loading Trailer: \(url.absoluteString)")
                    }
            } else {
                VStack {
                    Text("Trailer not available")
                        .foregroundColor(.white)
                        .padding()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Dismiss")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
        }
    }
}



