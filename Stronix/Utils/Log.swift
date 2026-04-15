//
//  Log.swift
//  Stronix
//
//  Created by Thiago Dias on 14/04/26.
//

import OSLog

enum Log {
    static let persistence = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Stronix", category: "Persistence")
    static let navigation = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Stronix", category: "Navigation")
}
