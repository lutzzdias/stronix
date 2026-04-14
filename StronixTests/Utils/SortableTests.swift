//
//  SortableTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
@testable import Stronix

class MockSortable: Sortable {
    var sortIndex: Int = 0
}

struct SortableTests {

    @Test
    func reorderAssignsSequentialIndices() {
        let items = [MockSortable(), MockSortable(), MockSortable()]
        items[0].sortIndex = 5
        items[1].sortIndex = 2
        items[2].sortIndex = 9
        
        items.reorder()
        
        #expect(items[0].sortIndex == 0)
        #expect(items[1].sortIndex == 1)
        #expect(items[2].sortIndex == 2)
    }
    
    @Test
    func reorderEmptyArray() {
        let items: [MockSortable] = []
        items.reorder()
        #expect(items.isEmpty)
    }
    
    @Test
    func reorderSingleElement() {
        let item = MockSortable()
        item.sortIndex = 42
        [item].reorder()
        #expect(item.sortIndex == 0)
    }
}
