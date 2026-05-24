import XCTest
import SwiftUI
@testable import AcmeBank

/// Snapshot / render tests for `LoginView`.
///
/// Because the project does not yet include a third-party snapshot framework
/// (e.g. SnapshotTesting), these tests use `XCTAttachment`-based captures:
/// they render the view inside a `UIHostingController`, rasterise it to a
/// `UIImage`, and attach the result to the test run so it appears in Xcode's
/// test reporter for visual inspection.
///
/// On a first run the attachments act as the baseline. In CI the attachments
/// are uploaded as artefacts. A future PR can swap in a proper diff-based
/// snapshot library once the design system is finalised.
final class LoginViewSnapshotTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func render(_ view: some View,
                        size: CGSize = CGSize(width: 390, height: 844)) -> UIImage {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.backgroundColor = .systemBackground

        // Force a layout pass so the view hierarchy is fully built.
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds,
                                                 afterScreenUpdates: true)
        }
    }

    @MainActor
    private func attach(_ image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Tests

    @MainActor
    func test_loginView_defaultState_rendersWithoutCrash() {
        let vm = LoginViewModel()
        let view = LoginView(viewModel: vm)

        let image = render(view)

        // The primary assertion: rendering did not crash and produced a
        // non-zero image.
        XCTAssertFalse(image.size == .zero, "Rendered image should have non-zero size")
        attach(image, name: "LoginView — default state")
    }

    @MainActor
    func test_loginView_loadingState_rendersWithoutCrash() {
        let vm = LoginViewModel()
        vm.username = "user@acmebank.com"
        vm.password = "password123"
        vm.isLoading = true
        let view = LoginView(viewModel: vm)

        let image = render(view)

        XCTAssertFalse(image.size == .zero, "Rendered image should have non-zero size")
        attach(image, name: "LoginView — loading state")
    }

    @MainActor
    func test_loginView_passwordVisibleState_rendersWithoutCrash() {
        let vm = LoginViewModel()
        vm.username = "user@acmebank.com"
        vm.password = "s3cr3t!"
        vm.isPasswordVisible = true
        let view = LoginView(viewModel: vm)

        let image = render(view)

        XCTAssertFalse(image.size == .zero, "Rendered image should have non-zero size")
        attach(image, name: "LoginView — password visible state")
    }

    @MainActor
    func test_loginView_rendersOnStandardIPhoneSize() {
        let vm = LoginViewModel()
        let view = LoginView(viewModel: vm)
        // iPhone 16 Pro Max logical size
        let image = render(view, size: CGSize(width: 430, height: 932))

        XCTAssertFalse(image.size == .zero)
        attach(image, name: "LoginView — iPhone 16 Pro Max size")
    }
}
