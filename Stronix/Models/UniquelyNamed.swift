//
//  UniquelyNamed.swift
//  Stronix
//

import Foundation
import SwiftData

/// A catalog model whose `name` must be unique, case- and whitespace-insensitively.
///
/// Conforming types get `isDuplicateName(_:excludingID:in:)` for free. Supply
/// `duplicateScope` to narrow which records participate (e.g. `Exercise` ignores
/// archived rows) and `nameComparisonProperties` to keep the fetch cheap.
protocol UniquelyNamed: PersistentModel {
    var name: String { get }
    var id: UUID { get }

    /// Restricts the uniqueness check to a subset of records. `nil` checks all.
    static var duplicateScope: Predicate<Self>? { get }

    /// Properties the duplicate check needs, so SwiftData can skip hydrating
    /// full objects. Declared per-type because SwiftData keypaths must resolve
    /// against the concrete `@Model`, not the protocol.
    static var nameComparisonProperties: [PartialKeyPath<Self>] { get }
}

extension UniquelyNamed {
    static var duplicateScope: Predicate<Self>? { nil }

    /// Checks whether `name` is already taken by another record in scope.
    /// - Parameters:
    ///   - name: The proposed name.
    ///   - excludingID: When editing, pass the current record's `id` so it doesn't match itself.
    ///   - context: The `ModelContext` used to query existing records.
    /// - Returns: `true` if another in-scope record has the same name (case-insensitive, trimmed).
    static func isDuplicateName(_ name: String, excludingID: UUID? = nil, in context: ModelContext) throws -> Bool {
        var descriptor = FetchDescriptor<Self>(predicate: duplicateScope)
        descriptor.propertiesToFetch = nameComparisonProperties
        let candidates = try context.fetch(descriptor)
        let target = name.normalizedForNameComparison
        return candidates.contains { candidate in
            candidate.name.normalizedForNameComparison == target && candidate.id != excludingID
        }
    }
}

extension String {
    /// Trimmed and lowercased, for comparing user-entered catalog names.
    var normalizedForNameComparison: String {
        trimmingCharacters(in: .whitespaces).lowercased()
    }
}
