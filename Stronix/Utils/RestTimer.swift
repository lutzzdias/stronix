//
//  RestTimer.swift
//  Stronix
//
//  Created by Thiago Dias on 14/04/26.
//

import Foundation
import UserNotifications

@Observable
class RestTimer {
    var start: Date?
    var duration: TimeInterval?
    var tick: Bool = false
    /// Toggled once when timer crosses zero — views can react with .sensoryFeedback
    var expired: Bool = false
    
    static let presets: [TimeInterval] = [60, 90, 120, 150, 180]
    
    private static let notificationId = "restTimerNotification"
    private static let startKey = "restTimerStart"
    private static let durationKey = "restTimerDuration"
    
    private var timer: Timer?
    private var hapticFired = false
    
    var isRunning: Bool {
        start != nil && duration != nil
    }
    
    var remainingTime: TimeInterval {
        guard let start, let duration else { return 0 }
        return duration - Date.now.timeIntervalSince(start)
    }
    
    init() {
        restoreFromDefaults()
    }
    
    func begin(duration: TimeInterval) {
        self.duration = duration
        self.start = Date.now
        hapticFired = false
        expired = false
        saveToDefaults()
        scheduleNotification(in: duration)
        startTicking()
    }
    
    func stop() {
        start = nil
        duration = nil
        hapticFired = false
        timer?.invalidate()
        timer = nil
        clearDefaults()
        cancelNotification()
    }
    
    func adjustDuration(by seconds: TimeInterval) {
        guard let duration else { return }
        let newDuration = duration + seconds
        if newDuration > 0 {
            self.duration = newDuration
            // Re-persist and reschedule notification with updated remaining time
            saveToDefaults()
            let remaining = remainingTime
            if remaining > 0 {
                scheduleNotification(in: remaining)
            } else {
                cancelNotification()
            }
        } else {
            stop()
        }
    }
    
    // MARK: - Ticking
    
    private func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.tick.toggle()
            // Signal once when timer crosses zero — view layer handles haptic
            if !self.hapticFired && self.isRunning && self.remainingTime <= 0 {
                self.hapticFired = true
                self.expired = true
            }
        }
    }
    
    // MARK: - UserDefaults Persistence
    
    private func saveToDefaults() {
        guard let start, let duration else { return }
        UserDefaults.standard.set(start.timeIntervalSince1970, forKey: Self.startKey)
        UserDefaults.standard.set(duration, forKey: Self.durationKey)
    }
    
    private func clearDefaults() {
        UserDefaults.standard.removeObject(forKey: Self.startKey)
        UserDefaults.standard.removeObject(forKey: Self.durationKey)
    }
    
    private func restoreFromDefaults() {
        let startEpoch = UserDefaults.standard.double(forKey: Self.startKey)
        let savedDuration = UserDefaults.standard.double(forKey: Self.durationKey)
        guard startEpoch > 0, savedDuration > 0 else { return }
        
        self.start = Date(timeIntervalSince1970: startEpoch)
        self.duration = savedDuration
        // If timer already expired, mark haptic as fired so it doesn't fire late
        hapticFired = remainingTime <= 0
        startTicking()
    }
    
    // MARK: - Local Notifications
    
    private func scheduleNotification(in seconds: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        
        // Cancel any existing notification before scheduling new one
        center.removePendingNotificationRequests(withIdentifiers: [Self.notificationId])
        
        guard seconds > 0 else { return }
        
        // Capture duration before closure to avoid accessing self.duration on background thread
        let displayDuration = duration ?? seconds
        
        // Schedule inside authorization callback to avoid race on first-ever permission request
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Rest timer done (\(AppFormatter.restTimer(displayDuration)))"
            content.body = "Back to work 💪"
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
            let request = UNNotificationRequest(identifier: Self.notificationId, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.notificationId])
    }
}
