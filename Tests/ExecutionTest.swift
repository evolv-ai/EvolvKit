//
//  ExecutionTest.swift
//  EvolvKit iOS Tests
//
//  Created by divbyzero on 30/07/2019.
//  Copyright © 2019 Evolv. All rights reserved.
//

import XCTest
@testable import EvolvKit

class ExecutionTest: XCTestCase {

    private var mockParticipant: EvolvParticipant!
    private var testValueInt: Int = 0
    private var testValueDouble: Double = 0
    
    override func setUp() {
        super.setUp()
        
        mockParticipant = EvolvParticipant.builder().build()
        testValueInt = 0
        testValueDouble = 0
    }

    override func tearDown() {
        super.tearDown()
        
        mockParticipant = nil
        testValueInt = 0
        testValueDouble = 0
    }

    func test_Init() {
        // given
        let key = "test"
        let defaultValue = 1

        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: defaultValue,
                                       participant: mockParticipant) { _ in }
        
        // then
        XCTAssertNotNil(execution)
        XCTAssertEqual(execution.key, key)
    }
    
    private func closureInt(value: Int) {
        testValueInt = value
    }
    
    private func closureDouble(value: Double) {
        testValueDouble = value
    }
    
    func test_ExecutionWithDefault() {
        // given
        let key = "test"
        let defaultValue = 1
        
        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: defaultValue,
                                       participant: mockParticipant,
                                       closure: closureInt)
        execution.executeWithDefault()
        
        // then
        XCTAssertNotNil(execution)
        XCTAssertEqual(testValueInt, defaultValue)
    }
    
    func test_ExecutionWithRawAllocations() {
        // given
        let rawAllocations = AllocationsTest.rawAllocations
        let key = "search.weighting.distance"
        let defaultValue = 2.5
        
        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: defaultValue,
                                       participant: mockParticipant,
                                       closure: closureDouble)
        
        do {
            try execution.execute(with: rawAllocations)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(execution)
        XCTAssertEqual(testValueDouble, defaultValue)
    }
    
    func test_DoubleExecutionWithRawAllocations() {
        // given
        let rawAllocations = AllocationsTest.rawAllocations
        let key = "search.weighting.distance"
        let defaultValue = 2.5
        var executionCounter = 0
        
        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: defaultValue,
                                       participant: mockParticipant,
                                       closure: { [weak self] value in
                                        executionCounter += 1
                                        self?.testValueDouble = value
        })
        
        do {
            try execution.execute(with: rawAllocations)
            try execution.execute(with: rawAllocations)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(execution)
        XCTAssertEqual(executionCounter, 1)
        XCTAssertEqual(testValueDouble, defaultValue)
    }

}
