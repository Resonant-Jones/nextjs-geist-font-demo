import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedTrack: Track?
    @State private var showDeleteAlert = false
    @State private var trackToDelete: Track?
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Favorites")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(viewModel.favoriteTracks.count) tracks")
                    .foregroundColor(.secondary)
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading favorites...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.favoriteTracks.isEmpty {
                EmptyFavoritesView()
            } else {
                // Favorites List
                List {
                    ForEach(viewModel.favoriteTracks) { track in
                        FavoriteTrackRow(track: track)
                            .contextMenu {
                                Button(action: {
                                    selectedTrack = track
                                }) {
                                    Label("View Details", systemImage: "info.circle")
                                }
                                
                                Button(action: {
                                    NSWorkspace.shared.open(track.permalinkUrl)
                                }) {
                                    Label("Open in Browser", systemImage: "safari")
                                }
                                
                                Divider()
                                
                                Button(role: .destructive, action: {
                                    trackToDelete = track
                                    showDeleteAlert = true
                                }) {
                                    Label("Remove from Favorites", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                selectedTrack = track
                            }
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(item: $selectedTrack) { track in
            TrackDetailView(track: track)
                .frame(width: 600, height: 400)
        }
        .alert("Remove from Favorites",
               isPresented: $showDeleteAlert,
               presenting: trackToDelete) { track in
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                Task {
                    await viewModel.removeFavorite(track)
                }
            }
        } message: { track in
            Text("Are you sure you want to remove \"\(track.title)\" from your favorites?")
        }
        .task {
            await viewModel.loadFavorites()
        }
    }
}

// MARK: - Favorite Track Row
struct FavoriteTrackRow: View {
    let track: Track
    @StateObject private var audioPlayer = AudioPlayer.shared
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Artwork
            AsyncImage(url: track.artworkUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, height: 50)
            .cornerRadius(4)
            
            // Track Info
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .lineLimit(1)
                    .font(.headline)
                
                Text(track.user.username)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Duration
            Text(track.durationFormatted)
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
            
            // Play Button
            if track.streamable {
                Button(action: {
                    if audioPlayer.currentTrack?.id == track.id {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            audioPlayer.play()
                        }
                    } else {
                        audioPlayer.play(track: track)
                    }
                }) {
                    Image(systemName: audioPlayer.currentTrack?.id == track.id && audioPlayer.isPlaying
                          ? "pause.fill"
                          : "play.fill")
                        .font(.title3)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .opacity(isHovered || audioPlayer.currentTrack?.id == track.id ? 1 : 0)
            }
        }
        .padding(.vertical, 4)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Empty State View
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your favorite tracks will appear here")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
