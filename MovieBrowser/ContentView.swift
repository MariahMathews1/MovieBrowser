import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MediaType = .movies
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Movie] = []

    enum MediaType: String, CaseIterable {
        case movies = "Movies"
        case tvShows = "TV Shows"
        case all = "All"
    }

    var body: some View {
        NavigationView {
            VStack {
                // **Search Bar**
                TextField("Search movies or TV shows...", text: $searchText, onEditingChanged: { editing in
                    if !editing {
                        isSearching = false
                    }
                })
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: searchText) { _, _ in
                    performSearch()
                }

                if isSearching {
                    // **Display search results in a vertical list**
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(searchResults) { movie in
                                NavigationLink(destination: MovieDetailView(movie: movie)) {
                                    HStack(spacing: 15) {
                                        // ✅ Movie Poster - Consistent Size
                                        if let posterURL = movie.posterURL {
                                            AsyncImage(url: posterURL) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 120)
                                                    .cornerRadius(8)
                                                    .clipped()
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 80, height: 120)
                                                    .cornerRadius(8)
                                            }
                                        }

                                        // ✅ Title - Fixed Frame for Consistency
                                        Text(movie.displayTitle)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2) // Prevents overly long titles from breaking layout
                                            .padding(.vertical, 5)
                                    }
                                    .frame(height: 130) // ✅ Ensures every row has the same height
                                    .padding(.horizontal)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                                }
                            }

                        }
                        .padding(.horizontal)
                    }
                } else {
                    // **Top Navigation Tabs**
                    Picker("Select Type", selection: $selectedTab) {
                        ForEach(MediaType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                                .fontWeight(.bold)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)

                    // **Content Display**
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
            .navigationTitle("Browse \(selectedTab.rawValue)")
        }
    }

    // **Perform Search Function**
    func performSearch() {
        if searchText.isEmpty {
            isSearching = false
            searchResults = []
            return
        }
        
        isSearching = true
        var allFetchedMovies: Set<Movie> = []
        let categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "trending/movie/day",
                          "tv/popular", "tv/on_the_air", "tv/top_rated", "trending/tv/day"]
        let dispatchGroup = DispatchGroup()
        
        for category in categories {
            let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
            let urlString = "https://api.themoviedb.org/3/\(category)?api_key=\(apiKey)&language=en-US&page=1"
            guard let url = URL(string: urlString) else { continue }
            
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                        DispatchQueue.main.async {
                            allFetchedMovies.formUnion(decodedResponse.results)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.searchResults = Array(allFetchedMovies).filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// **Reusable Horizontal Section for Movies & TV Shows**
struct HorizontalSectionView: View {
    let title: String
    let category: String
    @State private var items: [Movie] = []
    @Binding var searchText: String  // ✅ Bind to search text

    var filteredItems: [Movie] {
        searchText.isEmpty ? items : items.filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // **Section Title with "See More" Button**
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()

                Spacer()

                NavigationLink(destination: FullListView(category: category, title: title)) {
                    Text("See More →")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // **Horizontal Scroll List**
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: MovieDetailView(movie: item)) {
                            VStack {
                                if let posterURL = item.posterURL {
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
                                Text(item.displayTitle)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 220)
            .onAppear {
                fetchData()
            }
        }
    }

    func fetchData() {
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        let categories: [String]

        if category == "all_movies" {
            categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "movie/upcoming", "trending/movie/week"]
        } else if category == "all_tv" {
            categories = ["tv/popular", "tv/on_the_air", "tv/top_rated", "tv/airing_today", "trending/tv/week"]
        } else {
            categories = [category]
        }

        var fetchedItems = Set<Movie>()
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
                                fetchedItems.formUnion(decodedResponse.results)
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
                self.items = Array(fetchedItems).sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
                print("✅ Loaded \(self.items.count) items for \(category)")
            }
        }
    }
}
struct FullListView: View {
    let category: String
    let title: String
    @State private var items: [Movie] = []
    @State private var searchText = ""

    var filteredItems: [Movie] {
        searchText.isEmpty ? items : items.filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            // **Search Bar Inside the Full List View**
            TextField("Search \(title)...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink(destination: MovieDetailView(movie: item)) {
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

                                Text(item.displayTitle)
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
        .navigationTitle(title)
        .onAppear {
            fetchData()
        }
    }

    func fetchData() {
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        let categories: [String]

        if category == "all_movies" {
            categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "movie/upcoming", "trending/movie/week"]
        } else if category == "all_tv" {
            categories = ["tv/popular", "tv/on_the_air", "tv/top_rated", "tv/airing_today", "trending/tv/week"]
        } else {
            categories = [category]
        }

        var fetchedItems = Set<Movie>()
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
                                fetchedItems.formUnion(decodedResponse.results)
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
                self.items = Array(fetchedItems).sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
                print("✅ Loaded \(self.items.count) items for \(category)")
            }
        }
    }

}


#Preview {
    ContentView()
}
