import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthManager
    @AppStorage("downloadLocation") private var downloadLocation: String = "~/Downloads"
    @AppStorage("enableMediaControls") private var enableMediaControls = true
    @AppStorage("enableiCloudSync") private var enableiCloudSync = false
    @State private var showSignOutAlert = false
    @State private var showDirectoryPicker = false
    
    var body: some View {
        Form {
            Section("Account") {
                VStack(alignment: .leading) {
                    Text("Signed in to SoundCloud")
                        .font(.headline)
                    
                    Button("Sign Out", role: .destructive) {
                        showSignOutAlert = true
                    }
                    .padding(.top, 4)
                }
            }
            
            Section("Downloads") {
                HStack {
                    Text("Download Location:")
                    TextField("Download Path", text: $downloadLocation)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Choose...") {
                        showDirectoryPicker = true
                    }
                }
            }
            
            Section("Playback") {
                Toggle("Enable Media Controls", isOn: $enableMediaControls)
                    .onChange(of: enableMediaControls) { newValue in
                        // Update media controls configuration
                        UserDefaults.standard.set(newValue, forKey: "enableMediaControls")
                    }
            }
            
            Section("iCloud") {
                Toggle("Enable iCloud Sync", isOn: $enableiCloudSync)
                    .onChange(of: enableiCloudSync) { newValue in
                        // Update iCloud sync configuration
                        UserDefaults.standard.set(newValue, forKey: "enableiCloudSync")
                    }
                
                if enableiCloudSync {
                    Text("Favorites will be synced across your devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SoundCloud Client")
                        .font(.headline)
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                    
                    Link("View on GitHub",
                         destination: URL(string: "https://github.com/yourusername/soundcloud-client")!)
                }
            }
        }
        .padding()
        .frame(maxWidth: 600)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .fileImporter(
            isPresented: $showDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selectedURL = urls.first {
                    downloadLocation = selectedURL.path
                    UserDefaults.standard.set(selectedURL.path, forKey: "downloadLocation")
                }
            case .failure(let error):
                print("Directory picker error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthManager())
    }
}
