//
//  SoundEffectsTests.swift
//  Stronix
//

import Testing
import Foundation
@testable import Stronix

/// Tests for `SoundEffects.isEnabled(defaults:)` gating logic.
///
/// Uses an isolated `UserDefaults(suiteName:)` so tests do not mutate the
/// app's persistent defaults. Each test clears the suite before asserting.
struct SoundEffectsTests {
    private static let suiteName = "com.stronix.tests.SoundEffects"
    
    private func makeIsolatedDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: Self.suiteName)!
        defaults.removePersistentDomain(forName: Self.suiteName)
        return defaults
    }
    
    @Test
    func defaultsToEnabledWhenKeyAbsent() {
        let defaults = makeIsolatedDefaults()
        #expect(SoundEffects.isEnabled(defaults: defaults) == true)
    }
    
    @Test
    func respectsExplicitlyDisabled() {
        let defaults = makeIsolatedDefaults()
        defaults.set(false, forKey: SoundEffects.enabledKey)
        #expect(SoundEffects.isEnabled(defaults: defaults) == false)
    }
    
    @Test
    func respectsExplicitlyEnabled() {
        let defaults = makeIsolatedDefaults()
        defaults.set(true, forKey: SoundEffects.enabledKey)
        #expect(SoundEffects.isEnabled(defaults: defaults) == true)
    }
    
    @Test
    func toggleReflectsInReads() {
        let defaults = makeIsolatedDefaults()
        defaults.set(true, forKey: SoundEffects.enabledKey)
        #expect(SoundEffects.isEnabled(defaults: defaults) == true)
        defaults.set(false, forKey: SoundEffects.enabledKey)
        #expect(SoundEffects.isEnabled(defaults: defaults) == false)
    }
    
    @Test
    func enabledKeyIsStable() {
        // Guards against accidental renames that would silently reset users'
        // toggles. The key is also referenced by @AppStorage in SettingsView.
        #expect(SoundEffects.enabledKey == "soundEffectsEnabled")
    }
}
