import SwiftUI

/// Root content dispatcher.
///
/// Presents the unauthenticated `LoginView` until an auth session is
/// established. Authentication state management will be wired here in a
/// future PR when the Okta auth layer lands.
struct ContentView: View {
    var body: some View {
        LoginView(viewModel: LoginViewModel())
    }
}

#Preview {
    ContentView()
}
