//
//  Tag.swift
//  Stronix
//
//  Created by Thiago Dias on 12/08/24.
//

import Foundation

enum Tag: Codable {
    case drop
    case failure
    case warmUp
    
    var shortLabel: String {
        switch self {
        case .drop: "D"
        case .failure: "F"
        case .warmUp: "W"
        }
    }
}
