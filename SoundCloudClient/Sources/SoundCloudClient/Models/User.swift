import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: Int
    let username: String
    let avatarUrl: URL?
    let permalinkUrl: URL
    let followersCount: Int?
    let followingsCount: Int?
    let tracksCount: Int?
    let playlistCount: Int?
    let description: String?
    let country: String?
    let city: String?
    let website: URL?
    let websiteTitle: String?
    let verified: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatarUrl"
        case permalinkUrl = "permalinkUrl"
        case followersCount = "followersCount"
        case followingsCount = "followingsCount"
        case tracksCount = "tracksCount"
        case playlistCount = "playlistCount"
        case description
        case country
        case city
        case website = "website"
        case websiteTitle = "websiteTitle"
        case verified
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        
        if let avatarUrlString = try container.decodeIfPresent(String.self, forKey: .avatarUrl) {
            avatarUrl = URL(string: avatarUrlString)
        } else {
            avatarUrl = nil
        }
        
        permalinkUrl = try container.decode(URL.self, forKey: .permalinkUrl)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        followingsCount = try container.decodeIfPresent(Int.self, forKey: .followingsCount)
        tracksCount = try container.decodeIfPresent(Int.self, forKey: .tracksCount)
        playlistCount = try container.decodeIfPresent(Int.self, forKey: .playlistCount)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        
        if let websiteString = try container.decodeIfPresent(String.self, forKey: .website) {
            website = URL(string: websiteString)
        } else {
            website = nil
        }
        
        websiteTitle = try container.decodeIfPresent(String.self, forKey: .websiteTitle)
        verified = try container.decode(Bool.self, forKey: .verified)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helper
extension User {
    static var preview: User {
        User(
            id: 1,
            username: "Sample Artist",
            avatarUrl: URL(string: "https://example.com/avatar.jpg"),
            permalinkUrl: URL(string: "https://soundcloud.com/sample-artist")!,
            followersCount: 1000,
            followingsCount: 500,
            tracksCount: 30,
            playlistCount: 5,
            description: "This is a sample artist profile",
            country: "United States",
            city: "Los Angeles",
            website: URL(string: "https://example.com"),
            websiteTitle: "Artist Website",
            verified: true
        )
    }
}
