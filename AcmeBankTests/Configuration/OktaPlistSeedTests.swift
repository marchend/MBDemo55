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
/// and `Bundle.main.object(forInfoDictionaryKey:)` would return `nil` at
/// runtime — `AuthService` configuration would then fail with a confusing
/// "missing key" error far from the cause. This test catches that
/// regression at the unit-test layer.
final class OktaPlistSeedTests: XCTestCase {

    private static let requiredKeys = [
        "OktaIssuer",
        "OktaClientID",
        "OktaRedirectURI",
        "OktaScopes",
    ]

    func test_infoPlist_containsAllOktaSeedKeys() {
        let info = Bundle.main.infoDictionary ?? [:]
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
        let info = Bundle.main.infoDictionary ?? [:]
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
