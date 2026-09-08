import AudioToolbox
import UIKit

enum Feedback {
    static func shutter(sound: Bool, haptics: Bool) {
        if sound {
            AudioServicesPlaySystemSound(1108)
        }
        if haptics {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    static func success(haptics: Bool) {
        guard haptics else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func miss(haptics: Bool) {
        guard haptics else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}
