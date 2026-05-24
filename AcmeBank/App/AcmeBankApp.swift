import SwiftUI

@main
struct AcmeBankApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()   // ContentView owns the LoginViewModel and routes auth state
        }
    }
}
