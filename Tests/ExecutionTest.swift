//
//  ExecutionTest.swift
//
//  Copyright (c) 2019 Evolv Technology Solutions
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest
@testable import EvolvKit

class ExecutionTest: XCTestCase {

    private var mockParticipant: EvolvParticipant!
    private var mockAllocationStore: DefaultEvolvAllocationStore!
    private var testValueString: String = ""
    private var testValueInt: Int = 0
    private var testValueDouble: Double = 0
    private var testValueFloat: Float = 0
    private var testValueBool: Bool = false
    private var testValueArray: [Any] = []
    private var testValueDict: [String: Any] = [:]
    
    override func setUp() {
        super.setUp()
        
        mockParticipant = EvolvParticipant.builder().build()
        mockAllocationStore = DefaultEvolvAllocationStore(size: 5)
        testValueString = ""
        testValueInt = 0
        testValueDouble = 0
        testValueFloat = 0
        testValueBool = false
        testValueArray = []
        testValueDict = [:]
    }

    override func tearDown() {
        super.tearDown()
        
        mockParticipant = nil
        mockAllocationStore = nil
        testValueString = ""
        testValueInt = 0
        testValueDouble = 0
        testValueFloat = 0
        testValueBool = false
        testValueArray = []
        testValueDict = [:]
    }

    func test_Init() {
        // given
        let key = "test"
        let defaultValue = 1

        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: __N(defaultValue),
                                       participant: mockParticipant,
                                       store: mockAllocationStore) { _ in }
        
        // then
        XCTAssertNotNil(execution)
        XCTAssertEqual(execution.key, key)
    }
    
    private func closureString(node: EvolvRawAllocationNode) {
        testValueString = node.stringValue
    }
    
    private func closureInt(node: EvolvRawAllocationNode) {
        testValueInt = node.intValue
    }
    
    private func closureDouble(node: EvolvRawAllocationNode) {
        testValueDouble = node.doubleValue
    }
    
    private func closureFloat(node: EvolvRawAllocationNode) {
        testValueFloat = node.floatValue
    }
    
    private func closureBool(node: EvolvRawAllocationNode) {
        testValueBool = node.boolValue
    }
    
    private func closureArray(node: EvolvRawAllocationNode) {
        testValueArray = node.arrayValue
    }
    
    private func closureDict(node: EvolvRawAllocationNode) {
        testValueDict = node.dictionaryValue
    }
    
    func test_ExecutionWithDefault() {
        // given
        let key = "test"
        let defaultValue = 1
        
        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: __N(defaultValue),
                                       participant: mockParticipant,
                                       store: mockAllocationStore,
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
                                       defaultValue: __N(defaultValue),
                                       participant: mockParticipant,
                                       store: mockAllocationStore,
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
                                       defaultValue: __N(defaultValue),
                                       participant: mockParticipant,
                                       store: mockAllocationStore,
                                       closure: { [weak self] node in
                                        executionCounter += 1
                                        self?.testValueDouble = node.doubleValue
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
        let defaultArrayValue: [Any] = [1, "2", true, 12.345]
        let defaultDictValue: [String: Any] = ["temp": 1, "foo": ["bar": true]]
        
        // when
        let executionString = EvolvExecution(key: key,
                                             defaultValue: __N(defaultStringValue),
                                             participant: mockParticipant,
                                             store: mockAllocationStore,
                                             closure: closureString)
        let executionInt = EvolvExecution(key: key,
                                          defaultValue: __N(defaultIntValue),
                                          participant: mockParticipant,
                                          store: mockAllocationStore,
                                          closure: closureInt)
        let executionDouble = EvolvExecution(key: key,
                                             defaultValue: __N(defaultDoubleValue),
                                             participant: mockParticipant,
                                             store: mockAllocationStore,
                                             closure: closureDouble)
        let executionFloat = EvolvExecution(key: key,
                                            defaultValue: __N(defaultFloatValue),
                                            participant: mockParticipant,
                                            store: mockAllocationStore,
                                            closure: closureFloat)
        let executionBool = EvolvExecution(key: key,
                                           defaultValue: __N(defaultBoolValue),
                                           participant: mockParticipant,
                                           store: mockAllocationStore,
                                           closure: closureBool)
        let executionArray = EvolvExecution(key: key,
                                            defaultValue: __N(defaultArrayValue),
                                            participant: mockParticipant,
                                            store: mockAllocationStore,
                                            closure: closureArray)
        let executionDict = EvolvExecution(key: key,
                                           defaultValue: __N(defaultDictValue),
                                           participant: mockParticipant,
                                           store: mockAllocationStore,
                                           closure: closureDict)
        executionString.executeWithDefault()
        executionInt.executeWithDefault()
        executionDouble.executeWithDefault()
        executionFloat.executeWithDefault()
        executionBool.executeWithDefault()
        executionArray.executeWithDefault()
        executionDict.executeWithDefault()
        
        // then
        XCTAssertNotNil(executionString)
        XCTAssertNotNil(executionInt)
        XCTAssertNotNil(executionDouble)
        XCTAssertNotNil(executionFloat)
        XCTAssertNotNil(executionBool)
        XCTAssertNotNil(executionArray)
        XCTAssertNotNil(executionDict)
        XCTAssertEqual(testValueString, defaultStringValue)
        XCTAssertEqual(testValueInt, defaultIntValue)
        XCTAssertEqual(testValueDouble, defaultDoubleValue)
        XCTAssertEqual(testValueFloat, defaultFloatValue)
        XCTAssertEqual(testValueBool, defaultBoolValue)
        XCTAssertEqual(__N(testValueArray), __N(defaultArrayValue))
        XCTAssertEqual(__N(testValueDict), __N(defaultDictValue))
    }
    
    func test_ThrowsMismatchTypes() {
        // given
        let rawAllocations = TestData.rawAllocations
        let key = "search.weighting.distance"
        let defaultValue: [Int] = []
        
        // when
        let execution = EvolvExecution(key: key,
                                       defaultValue: __N(defaultValue),
                                       participant: mockParticipant,
                                       store: mockAllocationStore,
                                       closure: { _ in })
        
        // then
        XCTAssertThrowsError(try execution.execute(with: rawAllocations)) { error in
            XCTAssertEqual(error as! EvolvExecution.Error, EvolvExecution.Error.mismatchTypes)
        }
    }

}
