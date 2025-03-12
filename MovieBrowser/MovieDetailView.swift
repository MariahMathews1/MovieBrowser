import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @EnvironmentObject var watchlistManager: WatchlistManager //create watchlistManager for user watchlist

    var body: some View {
        ScrollView {
            ZStack {
                // **Backdrop Image**
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 350)
                            .overlay(
                                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                                               startPoint: .bottom,
                                               endPoint: .top)
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 350)
                    }
                }

                VStack {
                    // **Title Above Poster**
                    Text(movie.displayTitle) // ✅ FIX: Use a universal title for Movies & TV Shows
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)

                    // **Centered Poster Image**
                    if let posterURL = movie.posterURL {
                        AsyncImage(url: posterURL) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 200)
                                .cornerRadius(12)
                                .shadow(radius: 6)
                                .padding(.top, 20)
                        } placeholder: {
                            Image("placeholder_poster") //added a placeholder image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200)
                                .cornerRadius(12)
                                .shadow(radius: 6)
                                .padding(.top, 20)
                        }
                    }

                    // **Movie Stats - SF Symbols Instead of Emojis**
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(String(format: "%.1f", movie.voteAverage ?? 0.0))/10")
                            .foregroundColor(.white)
                            .bold()

                        Spacer()

                        Image(systemName: "calendar")
                            .foregroundColor(.white.opacity(0.7))
                        Text(movie.releaseDate ?? movie.firstAirDate ?? "Unknown Date") // ✅ FIX: Use correct date field for TV Shows & Movies
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)

                    // **Movie Description**
                    Text(movie.overview)
                        .foregroundColor(.white.opacity(0.9))
                        .font(.body)
                        .padding(.top, 10)
                        .padding(.horizontal)
                    
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
                    .padding(.horizontal)

                    Spacer()
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
