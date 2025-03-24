import SwiftUI

struct HorizontalSectionView: View {
    let title: String
    let category: String
    @State private var items: [Movie] = []
    @State private var hasLoaded = false
    @Binding var searchText: String  // ✅ Ensure this is here
    @Binding var selectedFilter: ContentView.BrowseFilter
    @EnvironmentObject var watchlistManager: WatchlistManager
    var isDarkMode: Bool

    var filteredItems: [Movie] {
        let limitedItems = items.prefix(20)

        return limitedItems.filter { movie in
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
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                    )

                Spacer()

                NavigationLink(destination: FullListView(category: category, title: title)) {
                    Text("See More →")
                        .foregroundColor(isDarkMode ? .white : .black)
                }
            }

            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: MovieDetailView(movie: item)) {
                            VStack {
                                if let posterURL = item.posterURL {
                                    ZStack(alignment: .topTrailing) {
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
                                        if watchlistManager.isWatched(item) {
                                            Text("Watched")
                                                .font(.caption2)
                                                .padding(4)
                                                .background(Color.black.opacity(0.7))
                                                .foregroundColor(.white)
                                                .cornerRadius(6)
                                                .padding(6)
                                        }
                                    }
                                }
                                Text(item.displayTitle)
                                    .font(.title3)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120)
                                    .lineLimit(2)
                                    .frame(width: 120, height: 40)
                                    .foregroundColor(isDarkMode ? .white : .black)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 220)
            .onAppear {
                if !hasLoaded {
                    fetchData()
                    hasLoaded = true
                }
            }
        }
    }

    func fetchData() {
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        let categories: [String]

        if category == "all_movies" {
                categories = ["movie/now_playing", "movie/top_rated", "movie/upcoming", "trending/movie/week"]
            } else if category == "all_tv" {
                categories = ["tv/on_the_air", "tv/top_rated", "tv/airing_today", "trending/tv/week"]
            } else {
                categories = [category]
            }

        var fetchedItems = [Int: Movie]() // ✅ Dictionary to track unique movies by ID
        let dispatchGroup = DispatchGroup()

        for cat in categories {
            for page in 1...5 {  // ✅ Fetch up to 5 pages per category
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
                                    fetchedItems[movie.id] = movie // ✅ Store movies uniquely by ID
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
                self.items = Array(fetchedItems.values).sorted(by: { ($0.popularity ?? 0) > ($1.popularity ?? 0) })
 // ✅ Convert dictionary back to an array
                print("✅ Loaded \(self.items.count) unique items for \(category)")
            }
        }
    }


}
