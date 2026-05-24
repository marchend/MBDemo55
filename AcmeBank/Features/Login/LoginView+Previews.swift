import SwiftUI

// MARK: - Design-iteration previews

#Preview("Default — empty fields") {
    let vm = LoginViewModel()
    // signIn stays at default no-op stub
    return LoginView(viewModel: vm)
}

#Preview("Loading state") {
    let vm = LoginViewModel()
    vm.username = "user@acmebank.com"
    vm.password = "password123"
    vm.isLoading = true
    return LoginView(viewModel: vm)
}

#Preview("Password visible") {
    let vm = LoginViewModel()
    vm.username = "user@acmebank.com"
    vm.password = "password123"
    vm.isPasswordVisible = true
    return LoginView(viewModel: vm)
}
