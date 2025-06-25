import Foundation

struct Track: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String?
    let duration: Int // in milliseconds
    let genre: String?
    let artworkUrl: URL?
    let streamUrl: URL?
    let permalinkUrl: URL
    let playbackCount: Int?
    let likeCount: Int?
    let commentCount: Int?
    let downloadable: Bool
    let streamable: Bool
    let createdAt: Date
    
    // User who created the track
    let user: User
    
    // Computed properties
    var durationFormatted: String {
        let totalSeconds = duration / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case duration
        case genre
        case artworkUrl = "artworkUrl"
        case streamUrl = "streamUrl"
        case permalinkUrl = "permalinkUrl"
        case playbackCount = "playbackCount"
        case likeCount = "likeCount"
        case commentCount = "commentCount"
        case downloadable
        case streamable
        case createdAt = "createdAt"
        case user
    }
    
    // Custom decoder to handle date formatting
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        genre = try container.decodeIfPresent(String.self, forKey: .genre)
        
        if let artworkUrlString = try container.decodeIfPresent(String.self, forKey: .artworkUrl) {
            artworkUrl = URL(string: artworkUrlString)
        } else {
            artworkUrl = nil
        }
        
        if let streamUrlString = try container.decodeIfPresent(String.self, forKey: .streamUrl) {
            streamUrl = URL(string: streamUrlString)
        } else {
            streamUrl = nil
        }
        
        permalinkUrl = try container.decode(URL.self, forKey: .permalinkUrl)
        playbackCount = try container.decodeIfPresent(Int.self, forKey: .playbackCount)
        likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount)
        downloadable = try container.decode(Bool.self, forKey: .downloadable)
        streamable = try container.decode(Bool.self, forKey: .streamable)
        
        // Parse the date string
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match expected format"
            )
        }
        
        user = try container.decode(User.self, forKey: .user)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helper
extension Track {
    static var preview: Track {
        Track(
            id: 1,
            title: "Sample Track",
            description: "This is a sample track description",
            duration: 180000, // 3 minutes
            genre: "Electronic",
            artworkUrl: URL(string: "https://example.com/artwork.jpg"),
            streamUrl: URL(string: "https://example.com/stream"),
            permalinkUrl: URL(string: "https://soundcloud.com/sample")!,
            playbackCount: 1000,
            likeCount: 50,
            commentCount: 10,
            downloadable: true,
            streamable: true,
            createdAt: Date(),
            user: .preview
        )
    }
}
