# ControlQPC iOS Panel

A dark SwiftUI dashboard prototype inspired by the supplied reference image.

## Current scope
- Native iOS dashboard UI with device selection, status panel, and feature tiles.
- All controls are demo-only and do not access a remote device.
- No covert camera/microphone capture, keylogging, private-message collection, or hidden surveillance is implemented.
- Real device-management features must use explicit enrollment, authenticated cloud APIs, and platform-supported permissions.

## Build
This project uses XcodeGen. On macOS with Xcode installed:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project ControlQPC.xcodeproj -scheme ControlQPC -sdk iphonesimulator -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

GitHub Actions runs the same simulator build and uploads the app bundle as an artifact. An installable device IPA requires an Apple signing identity and provisioning profile.
