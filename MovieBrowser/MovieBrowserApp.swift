//
//  MovieBrowserApp.swift
//  MovieBrowser
//
//  Created by Mariah Mathews on 3/8/25.
//

import SwiftUI

@main
struct MovieBrowserApp: App {
    @StateObject private var watchlistManager = WatchlistManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchlistManager)
        }
    }
}

