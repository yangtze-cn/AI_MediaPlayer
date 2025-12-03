import Foundation
import SwiftData

@Model
final class PlaybackHistoryItem {
    var id: UUID
    var videoTitle: String
    var videoUrlString: String
    var lastPlayedDate: Date
    var videoDescription: String
    var playbackTime: Double
    
    init(title: String, url: URL, description: String = "", playbackTime: Double = 0.0) {
        self.id = UUID()
        self.videoTitle = title
        self.videoUrlString = url.absoluteString
        self.lastPlayedDate = Date()
        self.videoDescription = description
        self.playbackTime = playbackTime
    }
    
    var videoUrl: URL? {
        URL(string: videoUrlString)
    }
}
