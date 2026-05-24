# Bootstrap Plan — AcmeBank iOS App

## In scope (this PR)

### Project name + tech stack decisions
- **App name:** AcmeBank
- **Platform:** iOS 17+, Swift 5.10, SwiftUI
- **Architecture:** MVVM + Coordinator (deferred; bootstrap uses SwiftUI @main entry only)
- **Project generation:** XcodeGen (`project.yml`) — never hand-crafted `.xcodeproj`
- **Test runner:** XCTest (unit tests in `AcmeBankTests/`)
- **Minimum Xcode:** 16.0
- **Bundle ID:** `com.acmebank.mobile`

### Directory structure (Hello World only)
```
.
├── project.yml                  # XcodeGen spec
├── setup.sh                     # One-shot setup script
├── .gitignore                   # iOS/XcodeGen/macOS ignores
├── bootstrap_plan.md
├── CLAUDE.md
├── AGENT.md
├── README.md
│
├── AcmeBank/
│   └── App/
│       ├── AcmeBankApp.swift    # @main SwiftUI entry (WindowGroup + ContentView)
│       └── ContentView.swift    # Placeholder "AcmeBank" label
│
└── AcmeBankTests/
    └── AcmeBankTests.swift      # ONE trivial test: ContentView initialises
```

### Files this PR creates
| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen spec (iOS 17+, unit-test target only) |
| `setup.sh` | Installs XcodeGen, generates .xcodeproj, opens in Xcode |
| `.gitignore` | Ignores generated Xcode artefacts, DS_Store, etc. |
| `AcmeBank/App/AcmeBankApp.swift` | `@main` SwiftUI App struct |
| `AcmeBank/App/ContentView.swift` | Placeholder `Text("AcmeBank")` view |
| `AcmeBankTests/AcmeBankTests.swift` | Trivial XCTest that instantiates ContentView |
| `CLAUDE.md` | Agent/dev guide (full planned architecture documented) |
| `AGENT.md` | Byte-identical copy of CLAUDE.md |
| `README.md` | Human-readable project overview |

### How to run the project locally
```bash
git clone <repo>
cd <repo>
./setup.sh   # installs xcodegen (if needed), generates .xcodeproj, opens Xcode
```
Manual fallback:
```bash
brew install xcodegen
xcodegen generate
open AcmeBank.xcodeproj
```

### How to run tests
In Xcode: `Cmd+U` on the `AcmeBank` scheme.
CLI: `xcodebuild test -scheme AcmeBank -destination 'platform=iOS Simulator,name=iPhone 16'`

### Definition of Hello World
The app launches and displays a single centered screen with the text **"AcmeBank"** on a system-background view. One XCTest passes confirming `ContentView()` initialises successfully.

---

## Out of scope — deferred to future work

- **Okta OIDC authentication** (AuthService, KeychainStore, UserSession, `okta-mobile-swift` SPM dependency) — future PR
- **MVVM + Coordinator pattern** (AppCoordinator, LoginCoordinator, TabBarCoordinator, HomeCoordinator, etc.) — future PR
- **RootView auth-state switching** (login vs. tab bar based on session) — future PR
- **Networking layer** (APIClient, APIRouter, APIError, RequestInterceptor, `API_BASE_URL` xcconfig) — future PR
- **Domain models** (Account, Transaction, Customer, TransferRequest, Address) — future PR
- **Repository protocols** (AccountRepositoryProtocol, TransactionRepositoryProtocol, etc.) — future PR
- **Remote data repositories** (AccountAPIRepository, TransactionAPIRepository, CustomerAPIRepository) — future PR
- **Mock data repositories** (MockAccountRepository, MockTransactionRepository, MockCustomerRepository) — future PR
- **Feature screens** (Login, Home, Accounts, Transfer, Cards, More) — future PRs per feature
- **Design system** (Colors.swift, Typography.swift, Assets.xcassets with brand colours) — future PR
- **Internal notifications** (AppNotification, NotificationPublisher, NotificationKey) — future PR
- **Extensions** (Decimal+Currency, Date+Greeting, String+Initials) — future PR
- **XCUITest target** (`AcmeBankUITests`) and critical-flow UI tests — future PR (first added when Login screen lands)
- **SwiftLint** (`.swiftlint.yml`, CI lint step) — future PR
- **CI pipeline** (`ios-build.yml`, `xcodebuild` with `-warnings-as-errors`, xcconfig injection) — future PR
- **Okta.plist.example** and `API_BASE_URL` xcconfig — future PR
- **Localizable.strings** — future PR
- **ViewModel unit tests** for feature screens (AuthServiceTests, LoginViewModelTests, HomeViewModelTests) — future PRs per feature
