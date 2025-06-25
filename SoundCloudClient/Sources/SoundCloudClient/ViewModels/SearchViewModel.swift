import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var tracks: [Track] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let api = SoundCloudAPI.shared
    
    func searchTracks(query: String) async {
        guard !query.isEmpty else {
            clearResults()
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            tracks = try await api.searchTracks(query: query)
        } catch {
            self.error = error
            tracks = []
        }
        
        isLoading = false
    }
    
    func clearResults() {
        tracks = []
        error = nil
    }
}

// MARK: - Error Types
extension SearchViewModel {
    enum SearchError: LocalizedError {
        case emptyQuery
        case networkError(String)
        
        var errorDescription: String? {
            switch self {
            case .emptyQuery:
                return "Please enter a search term"
            case .networkError(let message):
                return "Network error: \(message)"
            }
        }
    }
}

// MARK: - Preview Helper
extension SearchViewModel {
    static var preview: SearchViewModel {
        let viewModel = SearchViewModel()
        viewModel.tracks = [
            Track.preview,
            Track.preview,
            Track.preview
        ]
        return viewModel
    }
}
