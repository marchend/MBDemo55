import Foundation

/// ViewModel for the Login screen.
///
/// Holds all observable state for the login form and exposes an injectable
/// `signIn` closure so that the real auth integration can be swapped in by the
/// composition root without the view knowing.
final class LoginViewModel: ObservableObject {

    // MARK: - Published state

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isLoading: Bool = false

    // MARK: - Derived state

    /// `true` when both the username and password fields contain non-empty text,
    /// matching the AC requirement that the Sign-in button is disabled until
    /// both fields are filled in.
    var isSignInEnabled: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    // MARK: - Injectable dependencies

    /// Called by `performSignIn()`. Defaults to a no-op stub; the composition
    /// root (or tests) replace this with the real / mock implementation.
    var signIn: () async -> Void = {}

    // MARK: - Actions

    /// Executes the sign-in flow.
    ///
    /// Sets `isLoading = true` before awaiting `signIn()`, then resets it
    /// to `false` on completion (or if `signIn` throws — it is non-throwing
    /// by design so errors must be handled inside the closure itself).
    @MainActor
    func performSignIn() async {
        isLoading = true
        await signIn()
        isLoading = false
    }
}
