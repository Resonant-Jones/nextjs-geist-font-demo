# SoundCloud Client for macOS

A native macOS client for SoundCloud built with SwiftUI. This app provides a clean, modern interface for browsing and playing SoundCloud tracks.

## Features

- 🔐 **Secure Authentication**: OAuth2-based login with secure token storage
- 🔍 **Track Search**: Search for tracks with real-time results
- 🎵 **Track Details**: View comprehensive track information and metadata
- ❤️ **Favorites System**: Save tracks to your local favorites list
- 👤 **User Profiles**: View artist profiles and their latest uploads
- ⬇️ **Track Downloads**: Download tracks (when permitted)
- 🎧 **Audio Playback**: Built-in audio player with system media controls
- 🌙 **Dark Mode**: Automatic dark/light mode support
- ☁️ **iCloud Sync**: Optional iCloud sync for favorites (configurable)

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- SoundCloud API credentials

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/soundcloud-client.git
   cd soundcloud-client
   ```

2. Open the project in Xcode:
   ```bash
   open Package.swift
   ```

3. Add your SoundCloud API credentials:
   - Create a new app at [SoundCloud Developers](https://developers.soundcloud.com)
   - Copy your Client ID and Client Secret
   - Create a file named `Secrets.swift` in the Sources/SoundCloudClient directory:
     ```swift
     enum Secrets {
         static let clientId = "your_client_id"
         static let clientSecret = "your_client_secret"
     }
     ```

4. Build and run the project in Xcode

## Getting SoundCloud API Credentials

1. Visit [SoundCloud Developers](https://developers.soundcloud.com)
2. Sign in or create a new account
3. Create a new app
4. Set the Redirect URI to: `soundcloudclient://oauth/callback`
5. Copy the provided Client ID and Client Secret
6. Add these credentials to your `Secrets.swift` file

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses Swift Concurrency for asynchronous operations.

### Key Components

- **Models**: Data structures representing SoundCloud entities
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: API communication, authentication, and persistence

### Directory Structure

```
SoundCloudClient/
├── Sources/
│   └── SoundCloudClient/
│       ├── App/
│       │   └── SoundCloudClientApp.swift
│       ├── Models/
│       │   ├── Track.swift
│       │   └── User.swift
│       ├── Views/
│       │   ├── ContentView.swift
│       │   ├── SearchView.swift
│       │   └── ...
│       ├── ViewModels/
│       │   ├── SearchViewModel.swift
│       │   └── ...
│       └── Services/
│           ├── SoundCloudAPI.swift
│           ├── AuthManager.swift
│           └── ...
```

## Features in Detail

### Authentication
- Secure OAuth2 implementation
- Token storage in Keychain
- Automatic token refresh

### Search
- Real-time search results
- Rich track information display
- Artwork thumbnails

### Playback
- Native audio playback
- System media controls integration
- Background playback support

### Favorites
- Local storage using CoreData
- Optional iCloud sync
- Offline access to saved tracks

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SoundCloud API](https://developers.soundcloud.com/docs/api/guide) for providing the platform
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the modern UI framework
- The Swift community for various helpful packages and resources

## Support

For support, please open an issue in the GitHub repository or contact the maintainers.

---

**Note**: This is an unofficial client and is not affiliated with SoundCloud.
