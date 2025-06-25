// Rename this file to "Secrets.swift" and add your SoundCloud API credentials
enum Secrets {
    /// Your SoundCloud API Client ID
    /// Obtain this from https://developers.soundcloud.com
    static let clientId = "YOUR_CLIENT_ID"
    
    /// Your SoundCloud API Client Secret
    /// Obtain this from https://developers.soundcloud.com
    static let clientSecret = "YOUR_CLIENT_SECRET"
    
    /// OAuth Redirect URI
    /// Must match the redirect URI configured in your SoundCloud app settings
    static let redirectUri = "soundcloudclient://oauth/callback"
    
    /// API Base URL
    static let apiBaseUrl = "https://api.soundcloud.com"
}
