# AI_MediaPlayer

A simple media player application built with SwiftUI, demonstrating custom video playback controls and full-screen functionality with proper aspect ratio handling.

## Features

-   **Custom Video Playback:** Utilizes `AVPlayer` and `AVPlayerLayer` for flexible video rendering.
-   **Full-Screen Mode:** Seamless transition to full-screen video playback.
-   **Custom Controls:** Provides a custom progress bar, play/pause button, and full-screen toggle, replacing default system controls.
-   **Aspect Ratio Handling:** Ensures the entire video frame is visible, adding black bars (letterboxing/pillarboxing) as needed, instead of cropping the video.
-   **Audio Playback:** Supports audio playback for video files.

## Technologies Used

-   **SwiftUI:** For building the user interface.
-   **AVKit:** For media playback capabilities (`AVPlayer`, `AVPlayerLayer`).
-   **Xcode:** The integrated development environment for Apple platforms.

## Setup Instructions

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Xcode (version 15.0 or later recommended)
-   macOS (version 14.0 or later recommended)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/AI_MediaPlayer.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd AI_MediaPlayer
    ```
3.  **Open the project in Xcode:**
    ```bash
    open AI_MediaPlayer.xcodeproj
    ```
4.  **Select a Simulator or Device:** In Xcode, choose an iOS Simulator (e.g., iPhone 17 Pro) or a physical iOS device.
5.  **Build and Run:** Press `Cmd + R` or click the "Run" button in Xcode to build and run the application.

## Usage

-   The application will start playing a sample video (an Apple HLS stream).
-   Use the custom controls at the bottom of the screen to play/pause the video and toggle full-screen mode.
-   Drag the progress bar to seek through the video.

## Future Enhancements

-   Add support for different media sources (local files, other streaming protocols).
-   Implement more advanced playback controls (e.g., volume, skip forward/backward).
-   Improve error handling and loading states.
-   Add support for picture-in-picture.

## License

This project is licensed under the MIT License - see the LICENSE file for details. (Note: A LICENSE file is not included in this response, you may need to create one.)

