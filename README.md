# ControlQPC — Cloud Bot Studio

A monochrome, pure-black native SwiftUI dashboard concept for building, testing, and managing Discord bots from an iPhone.

## Current prototype
- Pure-black interface with monochrome panels and compact status cards.
- Local Test and Cloud mode selector.
- Bot name field, credential-field UI, command-builder module cards, and console preview.
- Local Test currently toggles a UI preview only; it does not run JavaScript or connect to Discord.
- Cloud mode is a setup placeholder; a secure backend and persistent bot runtime are required before real deployment.
- The credential field does not transmit or persist the token. Do not put real bot tokens in source code, logs, screenshots, or public repositories.

## Architecture needed for live bots
- iOS app: dashboard and configuration UI.
- Authenticated backend: user sessions, authorization, encrypted credential storage, and deployment API.
- Bot runtime: a separate Node.js process for official Discord bot applications.
- Local testing: a compatible local runtime or a browser-based simulator. iOS may suspend background work, so an iPhone cannot guarantee a continuously running bot.

Use official Discord bot applications and the Discord API. Do not use user-account tokens or self-bots.

## Build
This project uses XcodeGen. On macOS with Xcode installed:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project ControlQPC.xcodeproj -scheme ControlQPC -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

GitHub Actions runs a simulator build and uploads the app bundle as an artifact. Installing on a physical iPhone requires an appropriate signing identity and provisioning profile.
