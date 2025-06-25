import SwiftUI

struct TrackDetailView: View {
    let track: Track
    @StateObject private var audioPlayer = AudioPlayer.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isFavorite = false
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    
    private let coreDataManager = CoreDataManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with artwork and basic info
            HStack(alignment: .top, spacing: 20) {
                // Artwork
                AsyncImage(url: track.artworkUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                }
                .frame(width: 200, height: 200)
                .cornerRadius(8)
                .shadow(radius: 4)
                
                // Track Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(track.title)
                        .font(.title)
                        .lineLimit(2)
                    
                    Button(action: {
                        // Open user profile (to be implemented)
                    }) {
                        Text(track.user.username)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    
                    if let genre = track.genre {
                        Text(genre)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label(track.durationFormatted, systemImage: "clock")
                        
                        if let playbackCount = track.playbackCount {
                            Text("•")
                            Label("\(playbackCount) plays", systemImage: "play.circle")
                        }
                        
                        if let likeCount = track.likeCount {
                            Text("•")
                            Label("\(likeCount) likes", systemImage: "heart")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Description and controls
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Description
                    if let description = track.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        // Play/Pause
                        if track.streamable {
                            Button(action: togglePlayback) {
                                Label(
                                    audioPlayer.isPlaying && audioPlayer.currentTrack?.id == track.id
                                    ? "Pause"
                                    : "Play",
                                    systemImage: audioPlayer.isPlaying && audioPlayer.currentTrack?.id == track.id
                                    ? "pause.fill"
                                    : "play.fill"
                                )
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        // Favorite
                        Button(action: toggleFavorite) {
                            Label(
                                isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: isFavorite ? "heart.fill" : "heart"
                            )
                        }
                        .buttonStyle(.bordered)
                        
                        // Download
                        if track.downloadable {
                            Button(action: downloadTrack) {
                                if isDownloading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.8)
                                } else {
                                    Label("Download", systemImage: "arrow.down.circle")
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(isDownloading)
                        }
                        
                        // Share
                        ShareLink(
                            item: track.permalinkUrl,
                            message: Text("Check out \"\(track.title)\" on SoundCloud")
                        )
                        .buttonStyle(.bordered)
                        
                        // Open in Browser
                        Button(action: {
                            NSWorkspace.shared.open(track.permalinkUrl)
                        }) {
                            Label("Open in Browser", systemImage: "safari")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .task {
            // Check if track is favorited
            do {
                isFavorite = try coreDataManager.isFavorite(track)
            } catch {
                print("Error checking favorite status: \(error.localizedDescription)")
            }
        }
    }
    
    private func togglePlayback() {
        if audioPlayer.currentTrack?.id == track.id {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
        } else {
            audioPlayer.play(track: track)
        }
    }
    
    private func toggleFavorite() {
        do {
            if isFavorite {
                try coreDataManager.removeFavorite(track)
            } else {
                try coreDataManager.addFavorite(track)
            }
            isFavorite.toggle()
        } catch {
            print("Error toggling favorite: \(error.localizedDescription)")
        }
    }
    
    private func downloadTrack() {
        guard let streamUrl = track.streamUrl else { return }
        
        isDownloading = true
        
        Task {
            do {
                let downloadedUrl = try await SoundCloudAPI.shared.downloadTrack(url: streamUrl)
                print("Track downloaded to: \(downloadedUrl.path)")
                isDownloading = false
            } catch {
                print("Download error: \(error.localizedDescription)")
                isDownloading = false
            }
        }
    }
}

// MARK: - Preview
struct TrackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TrackDetailView(track: .preview)
    }
}
