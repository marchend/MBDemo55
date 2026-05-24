# AcmeBank — Agent & Developer Guide

## Project Overview
AcmeBank is a Swift/SwiftUI iOS banking app for Acme Bank customers. It will
let users authenticate via Okta OIDC, view accounts and transaction history,
initiate transfers, and manage cards — built on a clean MVVM + Coordinator
architecture with a `URLSession`-based networking layer.

## Tech Stack
| Item | Value |
|------|-------|
| Platform | iOS 17+ |
| Language | Swift 5.10 |
| UI Framework | SwiftUI |
| Architecture | MVVM + Coordinator (`NavigationStack`) |
| Auth | Okta OIDC (`okta-mobile-swift` 2.x, `WebAuthenticationUI`) |
| Networking | `URLSession` + async/await |
| Dependency Injection | Constructor injection (no service locator) |
| Notifications | `NotificationCenter` (typed wrappers) |
| Project generation | XcodeGen (`project.yml`) |
| Test runner | XCTest (unit) + XCUITest (critical flows) |
| Minimum Xcode | 16.0 |
| Bundle ID | `com.acmebank.mobile` |

## Running Locally
```bash
git clone <repo>
cd <repo>
./setup.sh        # installs XcodeGen if needed, generates .xcodeproj, opens Xcode
```
Manual fallback:
```bash
brew install xcodegen && xcodegen generate && open AcmeBank.xcodeproj
```

### Build prerequisites — Okta env vars
The app build phase injects Okta OIDC config into `Info.plist` from four
environment variables (`OKTA_ISSUER`, `OKTA_CLIENT_ID`, `OKTA_REDIRECT_URI`,
`OKTA_SCOPES`). The build **fails** if any is unset — no secrets file is
committed. See `README.md` § "Okta build configuration" for the two
supported setup paths (`launchctl setenv` vs `~/.zshrc` + `xed .`).

## Running Tests
- **Xcode:** `Cmd+U` on the `AcmeBank` scheme.
- **CLI:** `xcodebuild test -scheme AcmeBank -destination 'platform=iOS Simulator,name=iPhone 16'`

## Key Directory Structure
```
AcmeBank/
├── App/              # @main entry, RootView, AppCoordinator
├── Core/             # Auth, Networking, Notifications, Extensions
├── Domain/           # Models + Repository protocols
├── Data/             # Remote + Mock repository implementations
├── Features/         # Login, Home, Accounts, Transfer, Cards, More
└── DesignSystem/     # Colors, Typography, Assets.xcassets
AcmeBankTests/        # XCTest unit tests (mirrors AcmeBank/ structure)
AcmeBankUITests/      # XCUITest end-to-end tests (critical flows only)
```

## Planned Architecture

### MVVM + Coordinator
- **View** — SwiftUI `View` struct; renders from ViewModel `@Published` state; no business logic.
- **ViewModel** — `final class: ObservableObject`; holds state, calls repositories, posts notifications; no SwiftUI imports.
- **Coordinator** — `ObservableObject` owning `NavigationPath`; creates child Views + ViewModels; drives push/sheet/fullScreenCover declaratively. *(deferred — future PR)*
- **Repository protocols** — live in `Domain/`; concrete impls in `Data/`. ViewModels depend only on the protocol. *(deferred — future PR)*

### Coordinator Hierarchy *(deferred — future PR)*
```
AppCoordinator
  ├── LoginCoordinator   (full-screen when no session)
  └── TabBarCoordinator
        ├── HomeCoordinator
        ├── TransferCoordinator
        ├── CardsCoordinator
        └── MoreCoordinator
```

### Authentication *(deferred — future PR)*
Okta OIDC via `okta-mobile-swift` 2.x (SPM, product `WebAuthenticationUI`).
Config is read from `Info.plist` keys `OktaIssuer`, `OktaClientID`,
`OktaRedirectURI`, `OktaScopes` — seeded empty in `project.yml`, injected
at build time from env vars by the "Inject Okta config into Info.plist"
preBuildScript. `AuthService` persists tokens in Keychain.
`RequestInterceptor` refreshes tokens before each request; on failure posts
`AppNotification.sessionExpired` → `AppCoordinator` redirects to Login.

### Networking *(deferred — future PR)*
`APIClient` wraps `URLSession`; decodes with `.convertFromSnakeCase` + `.iso8601`.
`APIRouter` enum expresses every endpoint. `API_BASE_URL` injected via xcconfig.

### Design System *(deferred — future PR)*
`DesignSystem/Colors.swift` — brand Color constants (`acmeNavy`, `acmeBackground`, etc.)
`DesignSystem/Typography.swift` — Font scale helpers with Dynamic Type support.

### Internal Notifications *(deferred — future PR)*
`AppNotification` typed `Notification.Name` constants; `NotificationPublisher` posts them.
Coordinators subscribe; ViewModels never subscribe.

## Implementation Status
| Component | Status |
|-----------|--------|
| XcodeGen `project.yml` + SwiftUI Hello World | ✅ implemented in this PR |
| `setup.sh`, `.gitignore` | ✅ implemented in this PR |
| One trivial XCTest | ✅ implemented in this PR |
| Okta SPM dep + Info.plist build-time config | ✅ implemented (MD055-2 PR 1) |
| MVVM + Coordinator (all coordinators) | ⏳ deferred — future PR |
| Auth (Okta OIDC, AuthService, KeychainStore) | ⏳ deferred — future PR |
| Networking (APIClient, APIRouter, RequestInterceptor) | ⏳ deferred — future PR |
| Domain models (Account, Transaction, Customer, …) | ⏳ deferred — future PR |
| Repository protocols + Remote + Mock impls | ⏳ deferred — future PR |
| Feature screens (Login, Home, Accounts, Transfer, Cards) | ⏳ deferred — future PR |
| Design system (Colors, Typography, Assets) | ⏳ deferred — future PR |
| Internal notifications (AppNotification, NotificationPublisher) | ⏳ deferred — future PR |
| Extensions (Decimal+Currency, Date+Greeting, String+Initials) | ⏳ deferred — future PR |
| XCUITest target + critical-flow UI tests | ⏳ deferred — future PR |
| SwiftLint (`.swiftlint.yml`) | ⏳ deferred — future PR |
| CI pipeline (`ios-build.yml`, xcconfig injection) | ⏳ deferred — future PR |

## Git Workflow

> **Default PR target branch: `develop`.** Every feature/refactor/docs PR
> opens against `develop`. PRs are only opened against `qa`, `uat`, or
> `main` for explicit promotion PRs.

**Branch model (`develop` → `qa` → `uat` → `main`):**

| Branch  | Role                                 | Receives PRs from              | Promotes to |
|---------|--------------------------------------|--------------------------------|-------------|
| develop | Default integration branch           | feature branches               | qa          |
| qa      | First quality gate                   | develop (promotion PR)         | uat         |
| uat     | Pre-prod acceptance                  | qa (promotion PR)              | main        |
| main    | Production / release tags            | uat (promotion PR)             | tagged only |

All feature PRs MUST target `develop`. Never open a feature PR against
`qa`, `uat`, or `main`. Promotions happen via dedicated promotion PRs.
