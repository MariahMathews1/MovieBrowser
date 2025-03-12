//manages the watchlist functionality
import Foundation

class WatchlistManager: ObservableObject {
    @Published var watchlist: Set<Movie> = []
    
    private let watchlistKey = "watchlist"
    
    init() {
        loadWatchlist()
    }
    
    func addToWatchlist(_ movie: Movie) {
        watchlist.insert(movie)
        saveWatchlist()
    }
    
    func removeFromWatchlist(_ movie: Movie) {
        watchlist.remove(movie)
        saveWatchlist()
    }
    
    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlist.contains(movie)
    }
    
    private func saveWatchlist() {
        if let encoded = try? JSONEncoder().encode(Array(watchlist)) {
            UserDefaults.standard.set(encoded, forKey: watchlistKey)
        }
    }
    
    private func loadWatchlist() {
        if let savedData = UserDefaults.standard.data(forKey: watchlistKey),
           let decodedMovies = try? JSONDecoder().decode([Movie].self, from: savedData) {
            watchlist = Set(decodedMovies)
        }
    }
}

