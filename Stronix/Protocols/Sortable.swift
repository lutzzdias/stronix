//
//  Sortable.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

protocol Sortable: AnyObject {
    var sortIndex: Int { get set }
}

extension Array where Element: Sortable {
    func reorder() {
        for (index, element) in enumerated() {
            element.sortIndex = index
        }
    }
}
