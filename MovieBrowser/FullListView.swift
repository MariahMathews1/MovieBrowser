import SwiftUI

struct FullListView: View {
    let category: String
    let title: String
    @State private var items: [Movie] = []
    @State private var searchText = ""
    @State private var hasLoaded = false
    @State private var selectedFilter: ContentView.BrowseFilter = .all
    @EnvironmentObject var watchlistManager: WatchlistManager
    @Environment(\.colorScheme) var colorScheme


    var filteredItems: [Movie] {
        items.filter { movie in
            let matchesSearch = searchText.isEmpty || movie.displayTitle.lowercased().contains(searchText.lowercased())

            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .watched:
                matchesFilter = watchlistManager.isWatched(movie)
            case .unwatched:
                matchesFilter = !watchlistManager.isWatched(movie)
            case .liked:
                matchesFilter = watchlistManager.isLiked(movie)
            case .disliked:
                matchesFilter = watchlistManager.isDisliked(movie)
            }

            return matchesSearch && matchesFilter
        }
    }


    var body: some View {
        VStack {
            // **Search Bar for "See More" Page**
            TextField("Search \(title)...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            // **Filter Picker**
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

            // **Full List of Movies/TV Shows**
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: MovieDetailView(movie: item)) {
                            movieRowView(for: item)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(title)
        .onAppear {
            if !hasLoaded {
                fetchData()
                hasLoaded = true
            }
        }
    }

    // **Fetch Data for "See More" Page**
    func fetchData() {
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        var fetchedItems = [Int: Movie]() // ✅ Ensure uniqueness
        let dispatchGroup = DispatchGroup()
        
        // **Determine which API categories to fetch based on title**
        let categories: [String]
        
        if category == "all_movies" {
            categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "movie/upcoming", "trending/movie/week"]
        } else if category == "all_tv" {
            categories = ["tv/popular", "tv/on_the_air", "tv/top_rated", "tv/airing_today", "trending/tv/week"]
        } else {
            categories = [category]
        }

        for cat in categories {
            for page in 1...5 { // ✅ Fetch up to 5 pages per category
                let urlString = "https://api.themoviedb.org/3/\(cat)?api_key=\(apiKey)&language=en-US&page=\(page)"
                guard let url = URL(string: urlString) else { continue }

                dispatchGroup.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                    defer { dispatchGroup.leave() }

                    if let data = data {
                        do {
                            let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                            DispatchQueue.main.async {
                                for movie in decodedResponse.results {
                                    fetchedItems[movie.id] = movie // ✅ Store uniquely by ID
                                }
                            }
                        } catch {
                            print("❌ Error decoding JSON: \(error)")
                        }
                    }
                }.resume()
            }
        }

        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.items = Array(fetchedItems.values).sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
                print("✅ Loaded \(self.items.count) items for \(category)")
            }
        }
    }
    
    @ViewBuilder
    func movieRowView(for item: Movie) -> some View {
        HStack {
            if let posterURL = item.posterURL {
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

            VStack(alignment: .leading, spacing: 5) {
                Text(item.displayTitle)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                if watchlistManager.isWatched(item) {
                    Text("Watched")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if watchlistManager.isLiked(item) {
                    Text("Liked")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else if watchlistManager.isDisliked(item) {
                    Text("Disliked")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.leading, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }

}
