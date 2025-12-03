//
//  MediaPlayerApp.swift
//  MediaPlayer
//
//  Created by yangtze on 2025/6/26.
//

import SwiftUI
import SwiftData

@main
struct MediaPlayerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlaylistItem.self,
            PlaybackHistoryItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PlaylistView()
        }
        .modelContainer(sharedModelContainer)
    }
}
