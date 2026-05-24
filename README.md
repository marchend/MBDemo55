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

## Okta build configuration

The app reads its Okta OIDC configuration from `Info.plist` at runtime. The
values are **injected at build time** from environment variables by a Run
Script build phase declared in `project.yml`; no `Okta.plist`, `.xcconfig`,
or other secrets file is committed to the repo.

### Required environment variables

| Variable            | Example                                              |
|---------------------|------------------------------------------------------|
| `OKTA_ISSUER`       | `https://dev-123456.okta.com/oauth2/default`         |
| `OKTA_CLIENT_ID`    | `0oa1abcDEFghiJKL1d7`                                |
| `OKTA_REDIRECT_URI` | `com.acmebank.mobile:/callback`                      |
| `OKTA_SCOPES`       | `openid profile offline_access`                      |

If any of the four is unset, the build fails with a clear error from the
Run Script — there is no silent fallback.

### Setup option A — `launchctl setenv` (Xcode.app from Dock/Spotlight)

GUI-launched apps (Xcode opened from the Dock, Spotlight, or Finder) do
**not** inherit shell environment variables. To make them visible, set the
vars via `launchctl` and then relaunch Xcode:

```bash
launchctl setenv OKTA_ISSUER "https://dev-123456.okta.com/oauth2/default"
launchctl setenv OKTA_CLIENT_ID "0oa1abcDEFghiJKL1d7"
launchctl setenv OKTA_REDIRECT_URI "com.acmebank.mobile:/callback"
launchctl setenv OKTA_SCOPES "openid profile offline_access"

# Fully quit Xcode (Cmd+Q) and relaunch from the Dock.
```

These values persist for the login session. Re-run the `launchctl setenv`
commands after every reboot (or add them to a launch agent).

### Setup option B — `export` in `~/.zshrc` + launch Xcode from the shell

If you always open the project with `xed .` from a terminal, Xcode inherits
your shell environment:

```bash
# Add to ~/.zshrc (or ~/.bash_profile)
export OKTA_ISSUER="https://dev-123456.okta.com/oauth2/default"
export OKTA_CLIENT_ID="0oa1abcDEFghiJKL1d7"
export OKTA_REDIRECT_URI="com.acmebank.mobile:/callback"
export OKTA_SCOPES="openid profile offline_access"

# Then, from a new shell:
cd <repo>
xed .
```

Builds started from `xcodebuild` on the command line also pick up `export`-ed
vars automatically.

> **Heads up:** building without all four vars set fails the
> "Inject Okta config into Info.plist" Run Script — this is intentional, so
> a misconfigured environment can't produce a binary that silently points
> at the wrong issuer.

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
