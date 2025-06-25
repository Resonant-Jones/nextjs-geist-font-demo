import SwiftUI
import AuthenticationServices

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    private let keychainService = KeychainService()
    
    // SoundCloud OAuth2 configuration
    private let clientId = "" // Add your client ID
    private let clientSecret = "" // Add your client secret
    private let redirectUri = "soundcloudclient://oauth/callback"
    private let authEndpoint = "https://soundcloud.com/connect"
    private let tokenEndpoint = "https://api.soundcloud.com/oauth2/token"
    
    func authenticate() async {
        let authURL = buildAuthURL()
        
        do {
            let callbackURL = try await startOAuthFlow(authURL: authURL)
            let code = extractAuthCode(from: callbackURL)
            let token = try await exchangeCodeForToken(code: code)
            
            await MainActor.run {
                self.saveToken(token)
                self.isAuthenticated = true
            }
        } catch {
            print("Authentication error: \(error.localizedDescription)")
            await MainActor.run {
                self.isAuthenticated = false
            }
        }
    }
    
    private func buildAuthURL() -> URL {
        var components = URLComponents(string: authEndpoint)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: "non-expiring")
        ]
        return components.url!
    }
    
    private func startOAuthFlow(authURL: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let authSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "soundcloudclient"
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                }
            }
            
            authSession.presentationContextProvider = NSApplication.shared
            authSession.prefersEphemeralWebBrowserSession = true
            authSession.start()
        }
    }
    
    private func extractAuthCode(from url: URL) -> String {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        return components.queryItems?.first(where: { $0.name == "code" })?.value ?? ""
    }
    
    private func exchangeCodeForToken(code: String) async throws -> String {
        var request = URLRequest(url: URL(string: tokenEndpoint)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri
        ]
        
        request.httpBody = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return tokenResponse.accessToken
    }
    
    private func saveToken(_ token: String) {
        do {
            try keychainService.storeToken(token)
        } catch {
            print("Failed to save token: \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        keychainService.removeToken()
        isAuthenticated = false
    }
}

// Token response model
private struct TokenResponse: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension NSApplication: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}
