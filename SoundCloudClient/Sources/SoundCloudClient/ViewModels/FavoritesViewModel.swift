import SwiftUI
import CoreData

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteTracks: [Track] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let coreDataManager = CoreDataManager.shared
    
    func loadFavorites() async {
        isLoading = true
        error = nil
        
        do {
            let favorites = try coreDataManager.getAllFavorites()
            favoriteTracks = favorites.map { coreDataManager.convertToTrack($0) }
        } catch {
            self.error = error
            favoriteTracks = []
        }
        
        isLoading = false
    }
    
    func removeFavorite(_ track: Track) async {
        do {
            try coreDataManager.removeFavorite(track)
            await loadFavorites()
        } catch {
            self.error = error
        }
    }
    
    func addFavorite(_ track: Track) async {
        do {
            try coreDataManager.addFavorite(track)
            await loadFavorites()
        } catch {
            self.error = error
        }
    }
    
    func isFavorite(_ track: Track) -> Bool {
        do {
            return try coreDataManager.isFavorite(track)
        } catch {
            return false
        }
    }
}

// MARK: - Error Types
extension FavoritesViewModel {
    enum FavoritesError: LocalizedError {
        case failedToLoad
        case failedToSave
        case failedToDelete
        
        var errorDescription: String? {
            switch self {
            case .failedToLoad:
                return "Failed to load favorites"
            case .failedToSave:
                return "Failed to save favorite"
            case .failedToDelete:
                return "Failed to remove favorite"
            }
        }
    }
}

// MARK: - Preview Helper
extension FavoritesViewModel {
    static var preview: FavoritesViewModel {
        let viewModel = FavoritesViewModel()
        viewModel.favoriteTracks = [
            Track.preview,
            Track.preview,
            Track.preview
        ]
        return viewModel
    }
}
