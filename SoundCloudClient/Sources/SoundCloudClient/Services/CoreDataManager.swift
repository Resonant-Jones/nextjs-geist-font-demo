import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    private let containerName = "FavoriteTrack"
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: containerName)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        
        // Merge changes from parent contexts automatically
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Configure to keep only latest version of data
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - CRUD Operations
    
    func addFavorite(_ track: Track) throws {
        let favorite = FavoriteTrack(context: viewContext)
        favorite.id = Int64(track.id)
        favorite.title = track.title
        favorite.duration = Int64(track.duration)
        favorite.genre = track.genre
        favorite.artworkUrl = track.artworkUrl
        favorite.streamUrl = track.streamUrl
        favorite.permalinkUrl = track.permalinkUrl
        favorite.createdAt = track.createdAt
        favorite.favoriteDate = Date()
        favorite.userId = Int64(track.user.id)
        favorite.username = track.user.username
        
        try save()
    }
    
    func removeFavorite(_ track: Track) throws {
        let fetchRequest: NSFetchRequest<FavoriteTrack> = FavoriteTrack.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", track.id)
        
        let results = try viewContext.fetch(fetchRequest)
        results.forEach { viewContext.delete($0) }
        
        try save()
    }
    
    func isFavorite(_ track: Track) throws -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteTrack> = FavoriteTrack.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", track.id)
        
        let count = try viewContext.count(for: fetchRequest)
        return count > 0
    }
    
    func getAllFavorites() throws -> [FavoriteTrack] {
        let fetchRequest: NSFetchRequest<FavoriteTrack> = FavoriteTrack.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \FavoriteTrack.favoriteDate, ascending: false)
        ]
        
        return try viewContext.fetch(fetchRequest)
    }
    
    // MARK: - Helper Methods
    
    private func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    // Convert FavoriteTrack to Track
    func convertToTrack(_ favorite: FavoriteTrack) -> Track {
        Track(
            id: Int(favorite.id),
            title: favorite.title ?? "",
            description: nil,
            duration: Int(favorite.duration),
            genre: favorite.genre,
            artworkUrl: favorite.artworkUrl,
            streamUrl: favorite.streamUrl,
            permalinkUrl: favorite.permalinkUrl ?? URL(string: "https://soundcloud.com")!,
            playbackCount: nil,
            likeCount: nil,
            commentCount: nil,
            downloadable: false,
            streamable: favorite.streamUrl != nil,
            createdAt: favorite.createdAt ?? Date(),
            user: User(
                id: Int(favorite.userId),
                username: favorite.username ?? "",
                avatarUrl: nil,
                permalinkUrl: URL(string: "https://soundcloud.com")!,
                followersCount: nil,
                followingsCount: nil,
                tracksCount: nil,
                playlistCount: nil,
                description: nil,
                country: nil,
                city: nil,
                website: nil,
                websiteTitle: nil,
                verified: false
            )
        )
    }
}

// MARK: - Preview Helper
extension CoreDataManager {
    static var preview: CoreDataManager = {
        let manager = CoreDataManager()
        
        // Add some sample favorites for previews
        let track = Track.preview
        try? manager.addFavorite(track)
        
        return manager
    }()
}
