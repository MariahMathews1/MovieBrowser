import SwiftUI

struct ContentView: View {
    @State private var allMovies: [Movie] = []  // Store unique fetched movies
    @State private var searchText = ""
    @State private var selectedCategory: MovieCategory = .all

    // Movie Categories
    enum MovieCategory: String, CaseIterable {
        case all = "All Movies"
        case popular = "Popular"
        case nowPlaying = "Now Playing"
        case topRated = "Top Rated"
        case trending = "Trending"
    }

    // Search across ALL fetched movies, ensuring no duplicates
    var filteredMovies: [Movie] {
        let uniqueMovies = Array(Set(allMovies)) // Remove duplicates
        if searchText.isEmpty {
            return uniqueMovies
        } else {
            return uniqueMovies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search movies...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(MovieCategory.allCases, id: \.self) { category in
                        Text(category.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: selectedCategory) {
                    fetchAllMovies()
                }

                // Movie List (Displays all available unique movies)
                List(filteredMovies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack {
                            if let posterURL = movie.posterURL {
                                AsyncImage(url: posterURL) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 75)
                                        .cornerRadius(8)
                                } placeholder: {
                                    ProgressView()
                                }
                            }

                            Text(movie.title)
                                .font(.headline)
                                .padding(.leading, 10)
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .onAppear {
                fetchAllMovies()
            }
        }
    }

    // **Fetch Movies Based on Category, Ensuring No Duplicates**
    func fetchAllMovies() {
        let apiKey = "2cbd04c2dac25629f413b3b7d5feef97"
        allMovies.removeAll() // Clear previous movies

        let categories: [String]

        if selectedCategory == .all {
            // **"All Movies" is a mix of different lists**
            categories = ["movie/popular", "movie/now_playing", "movie/top_rated", "trending/movie/day"]
        } else {
            switch selectedCategory {
            case .popular:
                categories = ["movie/popular"]
            case .nowPlaying:
                categories = ["movie/now_playing"]
            case .topRated:
                categories = ["movie/top_rated"]
            case .trending:
                categories = ["trending/movie/day"]
            default:
                categories = []
            }
        }

        for categoryPath in categories {
            for page in 1...5 { // Fetch up to 5 pages per category
                let urlString = "https://api.themoviedb.org/3/\(categoryPath)?api_key=\(apiKey)&language=en-US&page=\(page)"

                guard let url = URL(string: urlString) else { return }

                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                            DispatchQueue.main.async {
                                let newMovies = decodedResponse.results
                                self.allMovies = Array(Set(self.allMovies + newMovies)) // Prevent duplicates
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }.resume()
            }
        }
    }
}

#Preview {
    ContentView()
}
