import XCTest
@testable import AcmeBank

/// Guards the four Okta Info.plist seed keys declared in `project.yml`.
///
/// The keys are seeded as empty strings in `targets.AcmeBank.info.properties`
/// and populated at build time by the "Inject Okta config into Info.plist"
/// Run Script from environment variables. This test only asserts the keys
/// *exist* in the host-app bundle — it deliberately does NOT assert on
/// their values, because:
///
///   • Local builds inject real values from `OKTA_*` env vars.
///   • CI / test-only builds may leave them as the seeded empty string.
///
/// If a future refactor of `project.yml` accidentally removes the seed
/// entries, the build product's Info.plist would silently lose the keys
/// and `Bundle(identifier:).object(forInfoDictionaryKey:)` would return
/// `nil` at runtime — `AuthService` configuration would then fail with a
/// confusing "missing key" error far from the cause. This test catches
/// that regression at the unit-test layer.
///
/// NOTE on bundle resolution: under XCTest, `Bundle.main` is the `xctest`
/// runner process, *not* the AcmeBank host app. The Okta seed keys live
/// in the app target's Info.plist, so we resolve the app bundle by its
/// bundle identifier and fall back to `.main` only as a safety net.
final class OktaPlistSeedTests: XCTestCase {

    private static let requiredKeys = [
        "OktaIssuer",
        "OktaClientID",
        "OktaRedirectURI",
        "OktaScopes",
    ]

    /// The AcmeBank host-app bundle (not the test runner). Resolved via
    /// the app's bundle identifier so the assertion runs against the
    /// Info.plist that actually ships in the app product.
    private var appBundle: Bundle {
        Bundle(identifier: "com.acmebank.mobile") ?? .main
    }

    private var appInfo: [String: Any] {
        appBundle.infoDictionary ?? [:]
    }

    func test_infoPlist_containsAllOktaSeedKeys() {
        let info = appInfo
        for key in Self.requiredKeys {
            XCTAssertNotNil(
                info[key],
                "Info.plist is missing required Okta seed key '\(key)'. " +
                "Check that `targets.AcmeBank.info.properties` in project.yml " +
                "still declares all four Okta* keys."
            )
        }
    }

    func test_infoPlist_oktaSeedKeysAreStrings() {
        let info = appInfo
        for key in Self.requiredKeys {
            // Allow empty string (seed default) or any populated string;
            // anything non-String means the seed type drifted.
            XCTAssertTrue(
                info[key] is String,
                "Info.plist key '\(key)' should be a String (got \(type(of: info[key] ?? "nil")))."
            )
        }
    }
}
