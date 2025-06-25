import Foundation

enum SoundCloudAPIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case unauthorized
    case notFound
    case serverError
    case unknown
}

actor SoundCloudAPI {
    static let shared = SoundCloudAPI()
    private let baseURL = "https://api.soundcloud.com"
    private let keychainService = KeychainService()
    
    private init() {}
    
    // MARK: - Track Search
    func searchTracks(query: String, limit: Int = 20) async throws -> [Track] {
        let endpoint = "/tracks"
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        return try await performRequest(
            endpoint: endpoint,
            queryItems: queryItems,
            responseType: [Track].self
        )
    }
    
    // MARK: - Track Details
    func getTrackDetails(id: Int) async throws -> Track {
        let endpoint = "/tracks/\(id)"
        return try await performRequest(
            endpoint: endpoint,
            responseType: Track.self
        )
    }
    
    // MARK: - User Profile
    func getUserProfile(id: Int) async throws -> User {
        let endpoint = "/users/\(id)"
        return try await performRequest(
            endpoint: endpoint,
            responseType: User.self
        )
    }
    
    // MARK: - User Tracks
    func getUserTracks(userId: Int, limit: Int = 20) async throws -> [Track] {
        let endpoint = "/users/\(userId)/tracks"
        let queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        
        return try await performRequest(
            endpoint: endpoint,
            queryItems: queryItems,
            responseType: [Track].self
        )
    }
    
    // MARK: - Generic Request Handler
    private func performRequest<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem] = [],
        responseType: T.Type
    ) async throws -> T {
        var components = URLComponents(string: baseURL + endpoint)
        
        // Get the auth token and add it as a query parameter
        let token = try keychainService.fetchToken()
        var allQueryItems = queryItems
        allQueryItems.append(URLQueryItem(name: "client_id", value: token))
        components?.queryItems = allQueryItems
        
        guard let url = components?.url else {
            throw SoundCloudAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SoundCloudAPIError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(responseType, from: data)
            case 401:
                throw SoundCloudAPIError.unauthorized
            case 404:
                throw SoundCloudAPIError.notFound
            case 500...599:
                throw SoundCloudAPIError.serverError
            default:
                throw SoundCloudAPIError.unknown
            }
        } catch let error as SoundCloudAPIError {
            throw error
        } catch let error as DecodingError {
            throw SoundCloudAPIError.decodingError(error)
        } catch {
            throw SoundCloudAPIError.networkError(error)
        }
    }
    
    // MARK: - Download Track
    func downloadTrack(url: URL) async throws -> URL {
        let (localURL, _) = try await URLSession.shared.download(from: url)
        
        // Move the downloaded file to the app's documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        
        // Remove any existing file
        try? FileManager.default.removeItem(at: destinationURL)
        
        // Move downloaded file to documents directory
        try FileManager.default.moveItem(at: localURL, to: destinationURL)
        
        return destinationURL
    }
}

// MARK: - API Response Models
extension SoundCloudAPI {
    struct APIResponse<T: Decodable>: Decodable {
        let data: T
    }
}
