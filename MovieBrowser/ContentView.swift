import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MediaType = .movies
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Movie] = []
    @EnvironmentObject var watchlistManager: WatchlistManager

    enum MediaType: String, CaseIterable {
        case movies = "Movies"
        case tvShows = "TV Shows"
        case all = "All"
        case watchlist = "Watchlist"
    }

    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                    // **Search Bar**
                    TextField("Search...", text: $searchText, onEditingChanged: { editing in
                        isSearching = editing
                    })
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onChange(of: searchText) { _, _ in performSearch() }
                    
                    if isSearching {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(searchResults) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        HStack(spacing: 15) {
                                            if let posterURL = movie.posterURL {
                                                AsyncImage(url: posterURL) { image in
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 120)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                } placeholder: {
                                                    Image("placeholder_poster")
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 120)
                                                        .cornerRadius(8)
                                                        .clipped()
                                                }
                                            }

                                            Text(movie.displayTitle)
                                                .font(.headline)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(2)
                                                .padding(.vertical, 5)
                                        }
                                        .frame(height: 130)
                                        .padding(.horizontal)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    else {
                        // **Tab Picker**
                        Picker("Select Type", selection: $selectedTab) {
                            ForEach(MediaType.allCases, id: \.self) { type in
                                Text(type.rawValue).fontWeight(.bold)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)

                        // **Content View**
                        if selectedTab == .watchlist {
                            WatchlistView()
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 20) {
                                    if selectedTab == .all || selectedTab == .movies {
                                        HorizontalSectionView(title: "All Movies", category: "all_movies", searchText: $searchText)
                                        HorizontalSectionView(title: "Popular Movies", category: "movie/popular", searchText: $searchText)
                                        HorizontalSectionView(title: "Trending Movies", category: "trending/movie/day", searchText: $searchText)
                                        HorizontalSectionView(title: "Top Rated Movies", category: "movie/top_rated", searchText: $searchText)
                                    }

                                    if selectedTab == .all || selectedTab == .tvShows {
                                        HorizontalSectionView(title: "All TV Shows", category: "all_tv", searchText: $searchText)
                                        HorizontalSectionView(title: "Popular TV Shows", category: "tv/popular", searchText: $searchText)
                                        HorizontalSectionView(title: "Trending TV Shows", category: "trending/tv/day", searchText: $searchText)
                                        HorizontalSectionView(title: "Top Rated TV Shows", category: "tv/top_rated", searchText: $searchText)
                                    }

                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .navigationTitle("Browse \(selectedTab.rawValue)")
            }
            
        }
    }

    // **Perform Search**
    func performSearch() {
        if searchText.isEmpty {
            isSearching = false
            searchResults = []
            return
        }

        isSearching = true
        var fetchedMovies = [Int: Movie]() // ✅ Dictionary to ensure unique movies by ID
        let dispatchGroup = DispatchGroup()
        
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        
        let categories: [String]
        switch selectedTab {
        case .movies:
            categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "trending/movie/day"]
        case .tvShows:
            categories = ["tv/popular", "tv/on_the_air", "tv/top_rated", "trending/tv/day"]
        case .all:
            categories = ["movie/popular", "tv/popular", "trending/all/week"]
        case .watchlist:
            searchResults = watchlistManager.watchlist.filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
            return
        }

        for category in categories {
            let urlString = "https://api.themoviedb.org/3/\(category)?api_key=\(apiKey)&language=en-US&page=1"
            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                        DispatchQueue.main.async {
                            for movie in decodedResponse.results {
                                fetchedMovies[movie.id] = movie // ✅ Ensuring unique movies
                            }
                        }
                    } catch {
                        print("❌ Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            self.searchResults = Array(fetchedMovies.values).filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
            print("✅ Search Results Count: \(self.searchResults.count)")
        }
    }

}

struct SearchResultsView: View {
    var searchResults: [Movie]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(searchResults) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack(spacing: 15) {
                            if let posterURL = movie.posterURL {
                                AsyncImage(url: posterURL) { image in
                                    image.resizable().scaledToFill()
                                        .frame(width: 80, height: 120)
                                        .cornerRadius(8)
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.3))
                                        .frame(width: 80, height: 120)
                                        .cornerRadius(8)
                                }
                            }
                            Text(movie.displayTitle)
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        .frame(height: 130)
                        .padding(.horizontal)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchlistManager())
}
