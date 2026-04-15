//
//  RestTimer.swift
//  Stronix
//
//  Created by Thiago Dias on 14/04/26.
//

import Foundation

// TODO: Send notification when timer reaches zero
// TODO: haptic feedback when timer reaches zero
// TODO: persist timer state in userDefaults so it survives app backgrounding
// TODO: configurable default duration

@Observable
class RestTimer {
    var start: Date?
    var duration: TimeInterval?
    var tick: Bool = false
    
    static let presets: [TimeInterval] = [60, 90, 120, 150, 180] // TODO: Get from settings
    
    private var timer: Timer?
    
    var isRunning: Bool {
        start != nil && duration != nil
    }
    
    var remainingTime: TimeInterval {
        guard let start, let duration else { return 0 }
        return duration - Date.now.timeIntervalSince(start)
    }
    
    func begin(duration: TimeInterval) {
        self.duration = duration
        self.start = Date.now
        startTicking()
    }
    
    func stop() {
        start = nil
        duration = nil
        timer?.invalidate()
        timer = nil
    }
    
    func adjustDuration(by seconds: TimeInterval) {
        guard let duration else { return }
        let newDuration = duration + seconds
        if newDuration > 0 {
            self.duration = newDuration
        } else {
            stop()
        }
    }
    
    private func startTicking() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick.toggle()
        }
    }
    
}
