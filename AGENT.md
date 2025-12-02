# AGENT.md

> **Purpose**: This document provides context, architectural guidelines, and development patterns for AI agents working on the `AI_MediaPlayer` project.

## 1. Project Overview

**AI_MediaPlayer** is a native iOS media player application built with **SwiftUI** and **AVFoundation**. It aims to provide a customizable and feature-rich video playback experience, replacing the standard system player with a bespoke UI and logic.

## 2. Architecture & Tech Stack

-   **Pattern**: MVVM (Model-View-ViewModel)
-   **UI Framework**: SwiftUI
-   **Media Framework**: AVKit / AVFoundation
-   **Reactive Framework**: Combine
-   **Language**: Swift 5+

### Core Components

| Component | Role | Key Responsibilities |
| :--- | :--- | :--- |
| **PlayerManager** | ViewModel | Manages `AVPlayer` instance, playback state (`isPlaying`, `currentTime`, `volume`, `rate`), and business logic. |
| **PlayerControlsView** | View | Renders the custom control bar (play/pause, seek, volume, full-screen). Binds directly to `PlayerManager`. |
| **VideoPlayerView** | View | Wraps `AVPlayerLayer` via `UIViewRepresentable` to render video content in SwiftUI. |
| **PlaylistView** | View | Displays the list of available videos and handles navigation to the player. |

## 3. State Management

State is primarily managed in `PlayerManager` (ObservableObject) and exposed via `@Published` properties.

-   **Single Source of Truth**: `PlayerManager` holds the state of the media player.
-   **Observation**: Views observe `PlayerManager` to update the UI.
-   **Optimistic Updates**: For operations like seeking or volume changes, update the published property *immediately* for UI responsiveness, then perform the async AVPlayer operation.

### Key State Properties
-   `isPlaying`: Boolean
-   `currentTime`: Double (seconds)
-   `duration`: Double (seconds)
-   `playbackRate`: Float (0.75x - 2.0x)
-   `volume`: Float (0.0 - 1.0)
-   `isMuted`: Boolean

## 4. Development Guidelines

### Code Style
-   **SwiftUI**: Use declarative syntax. Keep Views small and composable.
-   **Logic**: Put business logic in `PlayerManager`, not in the View `body`.
-   **Comments**: Use `MARK:` comments to organize code sections.

### Common Patterns
-   **Seeking**: When implementing seek, update `currentTime` immediately (optimistic update) to prevent the slider from jumping back.
-   **Icons**: Use SF Symbols for all UI icons.
-   **Time Formatting**: Use helper methods to format seconds into `MM:SS`.

### Git & Version Control
-   **Config Files**: Do NOT commit `*.xcuserstate` or `xcuserdata`. These are ignored in `.gitignore`.
-   **Compilation Check**: **MUST** run local compilation check after every code modification before committing:
    ```bash
    xcodebuild -project AI_MediaPlayer.xcodeproj -scheme AI_MediaPlayer \
      -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
    ```
    Ensure `** BUILD SUCCEEDED **` before proceeding with git commit.
-   **Commit Messages**: Use prefixed format for all commits:
    - `feat`: New features (e.g., "feat: add volume control and mute toggle")
    - `bugfix`: Bug fixes (e.g., "bugfix: fix seek progress delay")
    - `optimize`: Performance improvements (e.g., "optimize: improve slider responsiveness")
    - `arch`: Architecture changes (e.g., "arch: refactor PlayerManager state management")
    - `docs`: Documentation updates (e.g., "docs: update FEATURES.md")
    - `style`: Code style/formatting changes (e.g., "style: fix indentation")
    - `refactor`: Code refactoring without behavior change (e.g., "refactor: extract time formatting logic")
    - `test`: Adding or updating tests (e.g., "test: add unit tests for PlayerManager")
    - `chore`: Build/dependency updates (e.g., "chore: update gitignore")

## 5. Roadmap & Features

Refer to [FEATURES.md](FEATURES.md) for the detailed feature list and status.

**Current Focus**:
-   Enhancing playback controls (Volume, Mute, Seek).
-   Improving UI responsiveness.

**Future Goals**:
-   Picture-in-Picture (PiP).
-   Local file playback.
-   Playlist management with SwiftData.

## 6. Context for Agents

-   **Filesystem**: The project is located at `/Volumes/grow/Code/AI_MediaPlayer`.
-   **Running**: Cannot run the app directly in this environment. Rely on code analysis and manual verification steps (checking logic, compilation safety).
-   **Preview**: SwiftUI Previews are helpful but may require dummy data since we can't load remote URLs easily in this environment.
