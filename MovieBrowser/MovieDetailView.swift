import SwiftUI

struct MovieDetailView: View {
    let movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Movie Backdrop Image (Large Background)
                if let backdropURL = movie.backdropURL {
                    AsyncImage(url: backdropURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                    }
                }

                // Movie Title
                Text(movie.title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                // Rating & Release Date Section
                HStack {
                    if let releaseDate = movie.releaseDate {
                        Text("📅 Released: \(releaseDate)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("⭐️ \(String(format: "%.1f", movie.voteAverage))/10")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal)

                // Movie Poster
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(maxWidth: 250)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                }

                // Overview
                Text("Overview")
                    .font(.headline)
                    .padding(.horizontal)

                Text(movie.overview)
                    .font(.body)
                    .padding(.horizontal)
                    .foregroundColor(.gray)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MovieDetailView(movie: Movie(id: 1, title: "Example Movie", overview: "This is an example description.", posterPath: nil, backdropPath: nil, releaseDate: "2025-06-15", voteAverage: 8.5))
}
