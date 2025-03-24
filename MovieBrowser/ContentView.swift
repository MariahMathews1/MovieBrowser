import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MediaType = .movies
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Movie] = []
    @State private var selectedFilter: BrowseFilter = .all
    @AppStorage("isDarkMode") private var isDarkMode = true
    @EnvironmentObject var watchlistManager: WatchlistManager

    enum MediaType: String, CaseIterable {
        case movies = "Movies"
        case tvShows = "TV Shows"
        case all = "All"
        case watchlist = "Watchlist"
    }

    enum BrowseFilter: String, CaseIterable {
        case all = "All"
        case unwatched = "Unwatched"
        case watched = "Watched"
        case liked = "Liked"
        case disliked = "Disliked"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // App Title
                HStack {
                    Text("🎬 Bingeaholic")
                        .font(.system(size: 50, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                    Spacer()

                    // Theme Toggle
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                Text("Browse \(selectedTab.rawValue)")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)

                // Search Bar
                TextField("Search...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onChange(of: searchText) { _, newValue in
                        isSearching = !newValue.isEmpty
                        performSearch()
                    }

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
                                            .foregroundColor(isDarkMode ? .white : .black)
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
                } else {
                    // Tabs
                    Picker("Select Type", selection: $selectedTab) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            Text(type.rawValue).fontWeight(.bold)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Filter Picker
                    if selectedTab != .watchlist {
                        HStack(alignment: .center) {
                            Text("Filter:")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, -15)
                            Picker("Filter", selection: $selectedFilter) {
                                ForEach(BrowseFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 47)
                    }

                    // Content
                    if selectedTab == .watchlist {
                        WatchlistView()
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                if selectedTab == .all || selectedTab == .movies {
                                    horizontalSection("All Movies", category: "all_movies")
                                    horizontalSection("Popular Movies", category: "movie/popular")
                                    horizontalSection("Trending Movies", category: "trending/movie/day")
                                    horizontalSection("Top Rated Movies", category: "movie/top_rated")
                                }

                                if selectedTab == .all || selectedTab == .tvShows {
                                    horizontalSection("All TV Shows", category: "all_tv")
                                    horizontalSection("Popular TV Shows", category: "tv/popular")
                                    horizontalSection("Trending TV Shows", category: "trending/tv/day")
                                    horizontalSection("Top Rated TV Shows", category: "tv/top_rated")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    @ViewBuilder
    func horizontalSection(_ title: String, category: String) -> some View {
        HorizontalSectionView(
            title: title,
            category: category,
            searchText: $searchText,
            selectedFilter: $selectedFilter,
            isDarkMode: isDarkMode
        )
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
//        .modifier(GradientSectionTitle(title: title))
    }

    func performSearch() {
        if searchText.isEmpty {
            isSearching = false
            searchResults = []
            return
        }

        isSearching = true
        var fetchedMovies = [Int: Movie]()
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
            searchResults = watchlistManager.watchlist.filter {
                $0.displayTitle.lowercased().contains(searchText.lowercased())
            }
            return
        }

        for category in categories {
            let urlString = "https://api.themoviedb.org/3/\(category)?api_key=\(apiKey)&language=en-US&page=1"
            guard let url = URL(string: urlString) else { continue }

            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { dispatchGroup.leave() }
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                        DispatchQueue.main.async {
                            for movie in decodedResponse.results {
                                fetchedMovies[movie.id] = movie
                            }
                        }
                    } catch {
                        print("❌ JSON error: \(error)")
                    }
                }
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            self.searchResults = Array(fetchedMovies.values).filter {
                $0.displayTitle.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

// MARK: - Gradient Header Modifier
struct GradientSectionTitle: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
            content
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WatchlistManager())
}
