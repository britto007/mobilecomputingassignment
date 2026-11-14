# Firebase TodoApp (iOS / SwiftUI)

An iOS Todo-List app built with **SwiftUI (iOS 16+, MVVM)**, **Firebase Authentication (Email/Password)**, and **Cloud Firestore**.

## Features
- Email & Password Sign In / Sign Up (`FirebaseAuth`)
- Per-user task storage in Cloud Firestore (`users/{uid}/tasks/{taskId}`)
- Real-time task updates via Firestore snapshot listeners
- Full CRUD: Create, Read, Update (`title`, `description`, `isCompleted`), and Delete
- Unit-tested ViewModels with protocol-based service mocks

## Setup on macOS
1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if not already installed:
   ```bash
   brew install xcodegen
   ```
2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```
3. In Firebase Console:
   - Create a project and add an iOS app with bundle ID `com.example.TodoApp` (or update `project.yml`).
   - Download `GoogleService-Info.plist` and replace `TodoApp/Resources/GoogleService-Info.plist`.
   - Enable **Authentication → Sign-in method → Email/Password**.
   - Create a **Cloud Firestore** database and deploy `firebase/firestore.rules`.
4. Open `TodoApp.xcodeproj` in Xcode, wait for Swift Package Manager to resolve `firebase-ios-sdk`, and run on an iOS Simulator.

## Running Unit Tests
```bash
xcodebuild test -project TodoApp.xcodeproj -scheme TodoApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

