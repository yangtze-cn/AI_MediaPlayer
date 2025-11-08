
import Foundation

struct PlaylistItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let videoUrl: URL
}
