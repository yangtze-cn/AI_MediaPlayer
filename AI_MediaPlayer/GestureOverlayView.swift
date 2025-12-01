import SwiftUI

// MARK: - Gesture Type Enum
enum GestureType {
    case volume
    case brightness
    case progress(currentTime: Double, totalTime: Double)
}

// MARK: - Gesture Overlay View
struct GestureOverlayView: View {
    let gestureType: GestureType
    let value: Double // 0.0 - 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            // Value display
            Text(displayText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            // Progress bar for volume and brightness
            if case .volume = gestureType, true {
                progressBar
            } else if case .brightness = gestureType, true {
                progressBar
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
        )
        .shadow(radius: 10)
    }
    
    private var iconName: String {
        switch gestureType {
        case .volume:
            if value == 0 {
                return "speaker.slash.fill"
            } else if value < 0.33 {
                return "speaker.wave.1.fill"
            } else if value < 0.66 {
                return "speaker.wave.2.fill"
            } else {
                return "speaker.wave.3.fill"
            }
        case .brightness:
            return "sun.max.fill"
        case .progress:
            return "timer"
        }
    }
    
    private var displayText: String {
        switch gestureType {
        case .volume:
            return "音量 \(Int(value * 100))%"
        case .brightness:
            return "亮度 \(Int(value * 100))%"
        case .progress(let currentTime, let totalTime):
            return "\(formatTime(currentTime)) / \(formatTime(totalTime))"
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                // Foreground
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(value), height: 4)
            }
        }
        .frame(width: 120, height: 4)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        VStack(spacing: 40) {
            GestureOverlayView(gestureType: .volume, value: 0.7)
            GestureOverlayView(gestureType: .brightness, value: 0.5)
            GestureOverlayView(gestureType: .progress(currentTime: 125, totalTime: 300), value: 0.42)
        }
    }
}
