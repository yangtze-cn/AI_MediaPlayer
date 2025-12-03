import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlaybackHistoryItem.lastPlayedDate, order: .reverse) private var historyItems: [PlaybackHistoryItem]
    
    var body: some View {
        List {
            ForEach(historyItems) { item in
                if let videoUrl = item.videoUrl {
                    // Create a temporary PlaylistItem for the player
                    let playlistItem = PlaylistItem(
                        title: item.videoTitle,
                        description: item.videoDescription,
                        videoUrl: videoUrl
                    )
                    
                    NavigationLink(destination: PlayerView(playlistItem: playlistItem)) {
                        VStack(alignment: .leading) {
                            Text(item.videoTitle)
                                .font(.headline)
                            Text("Last played: \(item.lastPlayedDate.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("History")
        .overlay {
            if historyItems.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Videos you play will appear here.")
                )
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(historyItems[index])
            }
        }
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
