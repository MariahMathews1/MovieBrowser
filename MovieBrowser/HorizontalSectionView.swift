import SwiftUI

struct HorizontalSectionView: View {
    let title: String
    let category: String
    @State private var items: [Movie] = []
    @Binding var searchText: String  // ✅ Ensure this is here

    var filteredItems: [Movie] {
        let limitedItems = items.prefix(20) // ✅ Limit to 20 items
        return searchText.isEmpty ? Array(limitedItems) : limitedItems.filter { $0.displayTitle.lowercased().contains(searchText.lowercased()) }
    }


    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.title2)
                    .bold()

                Spacer()

                // **Navigation Link for "See More"**
                NavigationLink(destination: FullListView(category: category, title: title)) {
                    Text("See More →")
                        .foregroundColor(.blue)
                }


            }
            .padding(.horizontal)

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
                                    .lineLimit(2)
                                    .frame(width: 120, height: 40)
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
                self.items = Array(fetchedItems.values).sorted(by: { ($0.title ?? "") < ($1.title ?? "") }) // ✅ Convert dictionary back to an array
                print("✅ Loaded \(self.items.count) unique items for \(category)")
            }
        }
    }


}
