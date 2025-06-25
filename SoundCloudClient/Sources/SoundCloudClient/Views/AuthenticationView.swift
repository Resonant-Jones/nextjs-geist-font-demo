import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo and Title
            VStack(spacing: 16) {
                Image(systemName: "waveform")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
                
                Text("SoundCloud Client")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            // Description
            Text("Listen to your favorite tracks and discover new music")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Sign In Button
            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .scaleEffect(0.8)
                } else {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Sign in with SoundCloud")
                    }
                    .font(.headline)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
            .frame(width: 250)
            
            // Terms and Privacy
            VStack(spacing: 8) {
                Text("By continuing, you agree to our")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Link("Terms of Service",
                         destination: URL(string: "https://soundcloud.com/terms-of-use")!)
                    Text("and")
                        .foregroundColor(.secondary)
                    Link("Privacy Policy",
                         destination: URL(string: "https://soundcloud.com/privacy-policy")!)
                }
                .font(.caption)
            }
        }
        .frame(width: 400, height: 400)
        .alert("Authentication Error",
               isPresented: $showError,
               presenting: error) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    private func signIn() {
        isLoading = true
        
        Task {
            do {
                await authManager.authenticate()
            } catch {
                self.error = error
                self.showError = true
            }
            
            isLoading = false
        }
    }
}

// MARK: - Error Types
extension AuthenticationView {
    enum AuthError: LocalizedError {
        case cancelled
        case failed(String)
        
        var errorDescription: String? {
            switch self {
            case .cancelled:
                return "Authentication was cancelled"
            case .failed(let message):
                return "Authentication failed: \(message)"
            }
        }
    }
}

// MARK: - Preview
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthManager())
    }
}
