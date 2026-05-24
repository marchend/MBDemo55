import XCTest
@testable import AcmeBank

@MainActor
final class LoginViewModelTests: XCTestCase {

    // MARK: - State mutation

    func test_username_mutationUpdatesPublishedState() {
        let sut = LoginViewModel()
        sut.username = "user@acmebank.com"
        XCTAssertEqual(sut.username, "user@acmebank.com")
    }

    func test_password_mutationUpdatesPublishedState() {
        let sut = LoginViewModel()
        sut.password = "s3cr3t!"
        XCTAssertEqual(sut.password, "s3cr3t!")
    }

    func test_isPasswordVisible_defaultsToFalse() {
        let sut = LoginViewModel()
        XCTAssertFalse(sut.isPasswordVisible)
    }

    func test_isPasswordVisible_togglesCorrectly() {
        let sut = LoginViewModel()
        sut.isPasswordVisible = true
        XCTAssertTrue(sut.isPasswordVisible)
        sut.isPasswordVisible = false
        XCTAssertFalse(sut.isPasswordVisible)
    }

    func test_isLoading_defaultsToFalse() {
        let sut = LoginViewModel()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - performSignIn — loading state

    func test_performSignIn_setsIsLoadingTrueDuringExecution() async {
        let sut = LoginViewModel()
        var observedLoadingDuringSignIn = false

        sut.signIn = {
            observedLoadingDuringSignIn = sut.isLoading
        }

        await sut.performSignIn()

        XCTAssertTrue(observedLoadingDuringSignIn,
                      "isLoading should be true while signIn closure executes")
    }

    func test_performSignIn_resetsIsLoadingAfterCompletion() async {
        let sut = LoginViewModel()
        sut.signIn = { /* no-op */ }

        await sut.performSignIn()

        XCTAssertFalse(sut.isLoading,
                       "isLoading should be false after performSignIn returns")
    }

    // MARK: - performSignIn — closure invocation

    func test_performSignIn_callsSignInClosureExactlyOnce() async {
        let sut = LoginViewModel()
        var callCount = 0
        sut.signIn = { callCount += 1 }

        await sut.performSignIn()

        XCTAssertEqual(callCount, 1,
                       "signIn closure should be invoked exactly once per performSignIn() call")
    }

    func test_performSignIn_calledTwiceInvokesClosureTwice() async {
        let sut = LoginViewModel()
        var callCount = 0
        sut.signIn = { callCount += 1 }

        await sut.performSignIn()
        await sut.performSignIn()

        XCTAssertEqual(callCount, 2)
    }

    func test_performSignIn_defaultSignInClosureDoesNotThrow() async {
        let sut = LoginViewModel()
        // Default signIn is a no-op stub — just verify it doesn't crash.
        await sut.performSignIn()
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - performSignIn — isLoading transitions

    func test_performSignIn_isLoadingFalseBeforeAndAfter() async {
        let sut = LoginViewModel()
        XCTAssertFalse(sut.isLoading, "Pre-condition: isLoading starts false")
        sut.signIn = { /* no-op */ }

        await sut.performSignIn()

        XCTAssertFalse(sut.isLoading, "Post-condition: isLoading is false again")
    }
}
