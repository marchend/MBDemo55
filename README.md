# AcmeBank iOS App

A Swift/SwiftUI iOS banking app built with MVVM + Coordinator architecture,
Okta OIDC authentication, and a `URLSession`-based networking layer.

## Quick Start

```bash
git clone <repo>
cd <repo>
./setup.sh
```

The script installs [XcodeGen](https://github.com/yonaskolb/XcodeGen) via
Homebrew (if not already installed), generates `AcmeBank.xcodeproj` from the
declarative `project.yml`, and opens it in Xcode.

**Manual fallback** (for environments that block shell scripts):
```bash
brew install xcodegen
xcodegen generate
open AcmeBank.xcodeproj
```

## Requirements

- macOS 14+ with Xcode 16+
- iOS 17+ simulator or device
- [Homebrew](https://brew.sh) (for XcodeGen installation)

## Running Tests

```bash
xcodebuild test \
  -scheme AcmeBank \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or press `Cmd+U` in Xcode.

## Project Structure

```
AcmeBank/          — Application source (SwiftUI, MVVM, Coordinators)
AcmeBankTests/     — XCTest unit tests
project.yml        — XcodeGen project spec (source of truth)
setup.sh           — One-shot local setup script
```

See `CLAUDE.md` / `AGENT.md` for full architecture documentation and
the Git branching model.
