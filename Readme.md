# MYWORKHOURS

MYWORKHOURS is a SwiftUI-based iOS application for tracking daily work hours and break times.  
It focuses on clean architecture, modern SwiftUI patterns, and reliable local data persistence.

[![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/de/app/myworkhours/id6504833396?l=en-GB)

## 📱 Screenshots
<p float="left">
  <img src="https://www.yoiddev.com/MyWorkHoursImg/MyWork.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/Hours.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/Card.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/List.png" width="250" />
    <img src="https://www.yoiddev.com/MyWorkHoursImg/Details.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/EditView.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/Timer.png" width="250" />
  <img src="https://www.yoiddev.com/MyWorkHoursImg/Settings.png" width="250" />
</p>

## ✨ Features
- Fully built with **SwiftUI**
- **MVVM architecture**
- Async/Await for asynchronous tasks
- State management using `@State`, `@StateObject`, and `@Observable`
- Reusable and modular views
- Local data persistence using **Core Data**
- In-app subscriptions implemented using **StoreKit 2**
- Minimum deployment target: **iOS 17**

## 🧱 Architecture
The app follows **MVVM** to ensure scalability and testability:
- **Views** — UI layer built with SwiftUI
- **ViewModels** — business logic and state handling
- **Models** — Core Data entities
- **Services** — reusable app logic

## 🛠 Tech Stack
- Swift 5
- SwiftUI
- Async/Await
- Combine
- Core Data
- StoreKit 2 (in-app subscriptions)
- Xcode 16+

## 🚀 Requirements
- iOS 17+
- Xcode 16+
- macOS compatible with Xcode 16

## 🗺 Roadmap
- [ ] iCloud sync
- [ ] Export work reports
- [ ] Enhanced statistics and insights
- [ ] UI polish and accessibility improvements
