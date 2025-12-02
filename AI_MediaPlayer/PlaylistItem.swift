
import Foundation
import SwiftData

@Model
final class PlaylistItem {
    var id: UUID
    var title: String
    var itemDescription: String
    var videoUrlString: String
    
    init(title: String, description: String, videoUrl: URL) {
        self.id = UUID()
        self.title = title
        self.itemDescription = description
        self.videoUrlString = videoUrl.absoluteString
    }
    
    var videoUrl: URL? {
        URL(string: videoUrlString)
    }
    
    var description: String {
        itemDescription
    }
}
