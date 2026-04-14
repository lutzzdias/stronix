//
//  TagTests.swift
//  Stronix
//
//  Created by Thiago Dias on 13/04/26.
//

import Testing
@testable import Stronix

struct TagTests {
    
    @Test
    func allCasesExist() {
        let drop = Tag.drop
        let failure = Tag.failure
        let warmUp = Tag.warmUp
        
        #expect(drop == .drop)
        #expect(failure == .failure)
        #expect(warmUp == .warmUp)
    }
}
