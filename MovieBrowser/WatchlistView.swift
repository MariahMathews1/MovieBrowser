import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var watchlistManager: WatchlistManager

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
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(Array(watchlistManager.watchlist), id: \.id) { movie in
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

                                Text(movie.displayTitle)
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
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
