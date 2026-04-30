//
//  SoundEffects.swift
//  Stronix
//

import AudioToolbox
import Foundation

/// Plays short system sounds for UI micro-rewards.
///
/// System sounds are provided by iOS (no bundled assets) and respect the
/// device's silent switch. Playback is gated by the `soundEffectsEnabled`
/// `UserDefaults` key (default `true`). The gate is read lazily on each
/// call so `@AppStorage` toggles take effect immediately.
///
/// IDs reference `AudioToolbox`'s system sound catalog under
/// `/System/Library/Audio/UISounds/`. The subset used here:
/// - `1103` — Tink, for set completion.
enum SoundEffects {
    /// UserDefaults key controlling playback. Default: `true`.
    static let enabledKey = "soundEffectsEnabled"

    private enum SystemSoundID_: SystemSoundID {
        case tink = 1103
    }

    /// Plays the Tink sound (set completion feedback).
    static func playTink() {
        play(.tink)
    }

    private static func play(_ sound: SystemSoundID_) {
        guard isEnabled() else { return }
        AudioServicesPlaySystemSound(sound.rawValue)
    }

    /// Reads the enabled flag from the given defaults store.
    ///
    /// Defaults to `true` when the key is absent (first launch). The
    /// `defaults` parameter is injectable for testing.
    static func isEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: enabledKey) as? Bool ?? true
    }
}
