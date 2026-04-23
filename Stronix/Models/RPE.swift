//
//  RPE.swift
//  Stronix
//

import Foundation

/// Rate of Perceived Exertion (RPE) scale, 6.0–10.0 in 0.5 increments.
enum RPE: Double, Codable, CaseIterable {
    case six = 6.0
    case sixHalf = 6.5
    case seven = 7.0
    case sevenHalf = 7.5
    case eight = 8.0
    case eightHalf = 8.5
    case nine = 9.0
    case nineHalf = 9.5
    case ten = 10.0

    var label: String {
        String(format: "%g", rawValue)
    }

    var description: String {
        switch self {
        case .six:      "Could do 4+ more reps"
        case .sixHalf:  "Could do 3–4 more reps"
        case .seven:    "Could do 3 more reps"
        case .sevenHalf: "Could do 2–3 more reps"
        case .eight:    "Could do 2 more reps"
        case .eightHalf: "Could do 1–2 more reps"
        case .nine:     "Could do 1 more rep"
        case .nineHalf: "Maybe 1 more rep"
        case .ten:      "Maximum effort"
        }
    }
}
