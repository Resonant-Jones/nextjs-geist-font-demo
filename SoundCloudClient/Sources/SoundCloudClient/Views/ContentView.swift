import SwiftUI

struct ContentView: View {
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var audioPlayer = AudioPlayer.shared
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var selectedSidebarItem: SidebarItem = .search
    @State private var selectedTrack: Track?
    
    enum SidebarItem {
        case search
        case favorites
        case profile
        case settings
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedSidebarItem) {
                NavigationLink(value: SidebarItem.search) {
                    Label("Search", systemImage: "magnifyingglass")
                }
                
                NavigationLink(value: SidebarItem.favorites) {
                    Label("Favorites", systemImage: "heart.fill")
                }
                
                NavigationLink(value: SidebarItem.profile) {
                    Label("Profile", systemImage: "person.fill")
                }
                
                NavigationLink(value: SidebarItem.settings) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
        } detail: {
            // Main Content
            NavigationStack {
                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
        // Mini Player at the bottom
        .safeAreaInset(edge: .bottom) {
            if audioPlayer.currentTrack != nil {
                MiniPlayerView()
                    .frame(height: 60)
                    .background(.ultraThinMaterial)
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch selectedSidebarItem {
        case .search:
            SearchView(viewModel: searchViewModel)
        case .favorites:
            FavoritesView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil
        )
    }
}

// MARK: - Mini Player View
struct MiniPlayerView: View {
    @StateObject private var audioPlayer = AudioPlayer.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Artwork
            if let artworkUrl = audioPlayer.currentTrack?.artworkUrl {
                AsyncImage(url: artworkUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "music.note")
                        .foregroundColor(.secondary)
                }
                .frame(width: 40, height: 40)
                .cornerRadius(4)
            }
            
            // Track Info
            VStack(alignment: .leading) {
                Text(audioPlayer.currentTrack?.title ?? "")
                    .lineLimit(1)
                Text(audioPlayer.currentTrack?.user.username ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Playback Controls
            HStack(spacing: 20) {
                Button(action: { audioPlayer.seek(by: -15) }) {
                    Image(systemName: "gobackward.15")
                }
                
                Button(action: {
                    if audioPlayer.isPlaying {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                
                Button(action: { audioPlayer.seek(by: 15) }) {
                    Image(systemName: "goforward.15")
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Progress
            VStack(alignment: .trailing) {
                Text(formatTime(audioPlayer.currentTime))
                    .font(.caption)
                    .monospacedDigit()
                Text(formatTime(audioPlayer.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            .frame(width: 50)
        }
        .padding(.horizontal)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
    }
}
