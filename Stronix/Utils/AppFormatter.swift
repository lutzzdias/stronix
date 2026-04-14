//
//  AppFormatter.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Foundation

enum AppFormatter {
    private static let timer: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()
    
    private static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy 'at' HH:mm"
        return formatter
    }()
    
    static func duration(_ interval: TimeInterval) -> String {
        timer.string(from: interval) ?? ""
    }
    
    static func date(_ date: Date) -> String {
        dateTime.string(from: date)
    }
}
