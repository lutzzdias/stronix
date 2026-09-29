//
//  AppFormatterTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
import Foundation
@testable import Stronix

private let minute: TimeInterval = 60
private let hour: TimeInterval = 3600

struct AppFormatterTests {
    
    // MARK: - duration
    
    @Test
    func durationZero() {
        #expect(AppFormatter.duration(0) == "0m")
    }
    
    @Test
    func durationMinutesOnly() {
        let result = AppFormatter.duration(30 * minute) // 30 min
        #expect(result == "30m")
    }
    
    @Test
    func durationHoursOnly() {
        let result = AppFormatter.duration(2 * hour) // 2 hours
        #expect(result == "2h")
    }
    
    @Test
    func durationHoursAndMinutes() {
        let result = AppFormatter.duration(2 * hour + 15 * minute)
        #expect(result == "2h 15m")
    }
    
    // MARK: - date
    
    @Test
    func dateFormatsCorrectly() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        let components = DateComponents(year: 2026, month: 4, day: 13, hour: 21, minute: 30)
        let date = calendar.date(from: components)
        
        let result = AppFormatter.date(date!)
        #expect(result == "13 Apr 2026 at 21:30")
    }

    // MARK: - weight

    @Test
    func weightAppendsKilogramLabel() {
        #expect(AppFormatter.weight(22.5, in: .kilograms) == "22.5 kg")
    }

    @Test
    func weightInKilogramsShowsStoredValueUnchanged() {
        #expect(AppFormatter.weight(22.3456, in: .kilograms) == "22.3456 kg")
    }

    @Test
    func weightDropsTrailingZeros() {
        #expect(AppFormatter.weight(100, in: .kilograms) == "100 kg")
    }

    @Test
    func weightInPoundsConvertsAndRoundsToNearestHalf() {
        // 22.5 kg == 49.60462… lbs, shown as 49.5
        #expect(AppFormatter.weight(22.5, in: .pounds) == "49.5 lbs")
    }

    @Test
    func weightInPoundsNeverShowsKilogramLabel() {
        #expect(!AppFormatter.weight(20, in: .pounds).contains("kg"))
    }

    @Test
    func weightFormatsZero() {
        #expect(AppFormatter.weight(0, in: .kilograms) == "0 kg")
        #expect(AppFormatter.weight(0, in: .pounds) == "0 lbs")
    }
}
