import SwiftUI

/// The login screen.
///
/// Presents the AcmeBank logo, username/password fields (with a toggle to
/// reveal the password), a primary "Sign in" button, and a secondary
/// "Forgot password?" link.  All business logic lives in `LoginViewModel`.
struct LoginView: View {

    // MARK: - ViewModel

    @StateObject var viewModel: LoginViewModel

    // MARK: - Body

    var body: some View {
        ZStack {
            content
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Subviews

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

            logoSection

            fieldsSection

            signInButton

            forgotPasswordButton

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var logoSection: some View {
        // NOTE: Replace with `Image("AcmeBankLogo")` once the asset is added
        // to DesignSystem/Assets.xcassets in a future PR.
        VStack(spacing: 8) {
            Image(systemName: "building.columns.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(.blue)
                .accessibilityLabel("AcmeBank logo")
                .accessibilityHidden(true) // decorative — bank name label follows

            Text("AcmeBank")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 16) {
            TextField("Email address", text: $viewModel.username)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .accessibilityLabel("Email address")
                .accessibilityHint("Enter your AcmeBank email address")
                .accessibilityIdentifier("usernameField")
                .disabled(viewModel.isLoading)

            passwordField
        }
    }

    private var passwordField: some View {
        HStack {
            Group {
                if viewModel.isPasswordVisible {
                    TextField("Password", text: $viewModel.password)
                        .textContentType(.password)
                } else {
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .accessibilityLabel("Password")
            .accessibilityHint("Enter your AcmeBank password")
            .accessibilityIdentifier("passwordField")
            .disabled(viewModel.isLoading)

            Button {
                viewModel.isPasswordVisible.toggle()
            } label: {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel(viewModel.isPasswordVisible ? "Hide password" : "Show password")
            .accessibilityHint(viewModel.isPasswordVisible ? "Tap to hide your password" : "Tap to reveal your password")
            .accessibilityIdentifier("togglePasswordVisibilityButton")
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }

    private var signInButton: some View {
        Button {
            Task { await viewModel.performSignIn() }
        } label: {
            Text("Sign in")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoading ? Color.blue.opacity(0.6) : Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.isLoading)
        .accessibilityLabel("Sign in")
        .accessibilityHint("Double-tap to sign in to AcmeBank")
        .accessibilityIdentifier("signInButton")
    }

    private var forgotPasswordButton: some View {
        Button("Forgot password?") {
            // No-op — real navigation handled by a future coordinator PR.
        }
        .buttonStyle(.plain)
        .foregroundStyle(.blue)
        .accessibilityLabel("Forgot password")
        .accessibilityHint("Tap to reset your AcmeBank password")
        .accessibilityIdentifier("forgotPasswordButton")
    }

    private var loadingOverlay: some View {
        Color.black.opacity(0.25)
            .ignoresSafeArea()
            .overlay {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
                    .accessibilityLabel("Signing in")
            }
    }
}
