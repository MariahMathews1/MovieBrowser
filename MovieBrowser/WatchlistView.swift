import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var watchlistManager: WatchlistManager
    @State private var selectedFilter: ContentView.BrowseFilter = .all

    var filteredWatchlist: [Movie] {
        watchlistManager.watchlist.filter { movie in
            switch selectedFilter {
            case .all:
                return true
            case .watched:
                return watchlistManager.isWatched(movie)
            case .unwatched:
                return !watchlistManager.isWatched(movie)
            case .liked:
                return watchlistManager.isLiked(movie)
            case .disliked:
                return watchlistManager.isDisliked(movie)
            }
        }
    }

    var body: some View {
        if watchlistManager.watchlist.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "film.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray.opacity(0.5))

                Text("Your watchlist is empty.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack {
                // ✅ Filter Picker inside Watchlist
                HStack(alignment: .center) {
                    Text("Filter:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, -15)

                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(ContentView.BrowseFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 47)

                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(filteredWatchlist, id: \.id) { movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                HStack {
                                    if let posterURL = movie.posterURL {
                                        AsyncImage(url: posterURL) { image in
                                            image.resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 120)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 80, height: 120)
                                                .cornerRadius(8)
                                        }
                                    }

                                    VStack(alignment: .leading) {
                                        Text(movie.displayTitle)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)

                                        if watchlistManager.isWatched(movie) {
                                            Text("Watched")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        } else if watchlistManager.isLiked(movie) {
                                            Text("Liked")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        } else if watchlistManager.isDisliked(movie) {
                                            Text("Disliked")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.leading, 10)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
