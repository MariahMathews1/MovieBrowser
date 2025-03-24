// Controls the watchlist functionaliy
import Foundation

class WatchlistManager: ObservableObject {
    @Published var watchlist: Set<Movie> = []
    @Published var likedMovies: Set<Int> = []
    @Published var dislikedMovies: Set<Int> = []
    @Published var watchedMovies: Set<Int> = []

    private let watchlistKey = "watchlist"
    private let likesKey = "likedMovies"
    private let dislikesKey = "dislikedMovies"
    private let watchedKey = "watchedMovies"

    init() {
        loadWatchlist()
        loadThumbs()
        loadWatched()
    }

    // **Watchlist funcions**

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

    // **Like / Dislike Functions**

    func toggleLike(for movie: Movie) {
        if likedMovies.contains(movie.id) {
            likedMovies.remove(movie.id)
        } else {
            likedMovies.insert(movie.id)
            dislikedMovies.remove(movie.id)
        }
        saveThumbs()
    }

    func toggleDislike(for movie: Movie) {
        if dislikedMovies.contains(movie.id) {
            dislikedMovies.remove(movie.id)
        } else {
            dislikedMovies.insert(movie.id)
            likedMovies.remove(movie.id)
        }
        saveThumbs()
    }

    func isLiked(_ movie: Movie) -> Bool {
        likedMovies.contains(movie.id)
    }

    func isDisliked(_ movie: Movie) -> Bool {
        dislikedMovies.contains(movie.id)
    }

    private func saveThumbs() {
        UserDefaults.standard.set(Array(likedMovies), forKey: likesKey)
        UserDefaults.standard.set(Array(dislikedMovies), forKey: dislikesKey)
    }

    private func loadThumbs() {
        if let liked = UserDefaults.standard.array(forKey: likesKey) as? [Int] {
            likedMovies = Set(liked)
        }
        if let disliked = UserDefaults.standard.array(forKey: dislikesKey) as? [Int] {
            dislikedMovies = Set(disliked)
        }
    }
    
    private func saveWatched() {
        UserDefaults.standard.set(Array(watchedMovies), forKey: watchedKey)
    }
    
    private func loadWatched() {
        if let watched = UserDefaults.standard.array(forKey: watchedKey) as? [Int] {
            watchedMovies = Set(watched)
        }
    }
    
    func toggleWatched(for movie: Movie) {
        if watchedMovies.contains(movie.id) {
            watchedMovies.remove(movie.id)
        } else {
            watchedMovies.insert(movie.id)
        }
        saveWatched()
    }
    
    func isWatched(_ movie: Movie) -> Bool {
        watchedMovies.contains(movie.id)
    }
}
