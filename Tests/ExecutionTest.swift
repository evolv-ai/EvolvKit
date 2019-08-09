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
    private var testValueString: String = ""
    private var testValueInt: Int = 0
    private var testValueDouble: Double = 0
    private var testValueFloat: Float = 0
    private var testValueBool: Bool = false
    
    override func setUp() {
        super.setUp()
        
        mockParticipant = EvolvParticipant.builder().build()
        testValueString = ""
        testValueInt = 0
        testValueDouble = 0
        testValueFloat = 0
        testValueBool = false
    }

    override func tearDown() {
        super.tearDown()
        
        mockParticipant = nil
        testValueString = ""
        testValueInt = 0
        testValueDouble = 0
        testValueFloat = 0
        testValueBool = false
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
    
    private func closureString(value: String) {
        testValueString = value
    }
    
    private func closureInt(value: Int) {
        testValueInt = value
    }
    
    private func closureDouble(value: Double) {
        testValueDouble = value
    }
    
    private func closureFloat(value: Float) {
        testValueFloat = value
    }
    
    private func closureBool(value: Bool) {
        testValueBool = value
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
        let rawAllocations = TestData.rawAllocations
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
        let rawAllocations = TestData.rawAllocations
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
    
    func test_TypeSupport() {
        // given
        let key = "test"
        let defaultStringValue = ""
        let defaultIntValue = 1
        let defaultDoubleValue: Double = 1
        let defaultFloatValue: Float = 1
        let defaultBoolValue = true
        
        // when
        let executionString = EvolvExecution(key: key, defaultValue: defaultStringValue, participant: mockParticipant, closure: closureString)
        let executionInt = EvolvExecution(key: key, defaultValue: defaultIntValue, participant: mockParticipant, closure: closureInt)
        let executionDouble = EvolvExecution(key: key, defaultValue: defaultDoubleValue, participant: mockParticipant, closure: closureDouble)
        let executionFloat = EvolvExecution(key: key, defaultValue: defaultFloatValue, participant: mockParticipant, closure: closureFloat)
        let executionBool = EvolvExecution(key: key, defaultValue: defaultBoolValue, participant: mockParticipant, closure: closureBool)
        executionString.executeWithDefault()
        executionInt.executeWithDefault()
        executionDouble.executeWithDefault()
        executionFloat.executeWithDefault()
        executionBool.executeWithDefault()
        
        // then
        XCTAssertNotNil(executionString)
        XCTAssertNotNil(executionInt)
        XCTAssertNotNil(executionDouble)
        XCTAssertNotNil(executionFloat)
        XCTAssertNotNil(executionBool)
        XCTAssertEqual(testValueString, defaultStringValue)
        XCTAssertEqual(testValueInt, defaultIntValue)
        XCTAssertEqual(testValueDouble, defaultDoubleValue)
        XCTAssertEqual(testValueFloat, defaultFloatValue)
        XCTAssertEqual(testValueBool, defaultBoolValue)
    }
    
    func test_ThrowsMismatchTypes() {
        // given
        let rawAllocations = TestData.rawAllocations
        let key = "search.weighting.distance"
        let defaultValue: [Int] = []
        
        // when
        let execution = EvolvExecution(key: key, defaultValue: defaultValue, participant: mockParticipant, closure: { _ in })
        
        // then
        XCTAssertThrowsError(try execution.execute(with: rawAllocations)) { error in
            XCTAssertEqual(error as! EvolvKeyError, EvolvKeyError.mismatchTypes)
        }
    }

}
