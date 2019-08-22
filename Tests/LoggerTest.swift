//
//  LoggerTest.swift
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

class LoggerTest: XCTestCase {
    
    private var logger: EvolvLogger?

    override func setUp() {
        super.setUp()
        
        logger = EvolvLogger.shared
    }

    override func tearDown() {
        super.tearDown()
        
        logger = nil
    }
    
    func test_ChangeLogLevel() {
        // given
        logger?.logLevel = .error
        
        // when
        logger?.logLevel = .debug
        
        // then
        XCTAssertEqual(logger?.logLevel, EvolvLogLevel.debug)
    }
    
    func test_InfoMessage() {
        // given
        logger?.logLevel = .info
        
        // when
        logger?.info("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit] abc")
    }

    func test_DebugMessage() {
        // given
        logger?.logLevel = .debug
        
        // when
        logger?.debug("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit][Debug] abc")
    }
    
    func test_ErrorMessage() {
        // given
        logger?.logLevel = .error
        
        // when
        logger?.error("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit][Error] abc")
    }
    
    func test_InfoLogLevel() {
        // given
        logger?.logLevel = .info
        
        // when
        logger?.debug("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, nil)
    }
    
    func test_DebugLogLevel() {
        // given
        logger?.logLevel = .debug
        
        // when
        logger?.error("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, nil)
    }
    
    func test_LessLogLevel1() {
        // given
        logger?.logLevel = .debug
        
        // when
        logger?.info("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit] abc")
    }
    
    func test_LessLogLevel2() {
        // given
        logger?.logLevel = .error
        
        // when
        logger?.debug("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit][Debug] abc")
    }
    
    func test_LessLogLevel3() {
        // given
        logger?.logLevel = .error
        
        // when
        logger?.info("abc")
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit] abc")
    }
    
    func test_LogNil() {
        // given
        let temp: String? = nil
        
        // when
        logger?.info(temp)
        
        // then
        XCTAssertEqual(logger?.logMessage, nil)
    }
    
    func test_LogEnum() {
        // given
        // swiftlint:disable nesting
        enum Temp {
            case aaa
            case bbb
        }
        
        let temp: Temp = .aaa
        
        // when
        logger?.info(temp)
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit] aaa")
    }
    
    func test_LogStruct() {
        // given
        // swiftlint:disable nesting
        struct Foo {
            let description: String
            let value: Int
            let bar: Bool
        }
        
        let temp: Foo = Foo(description: "temp", value: 1, bar: true)
        
        // when
        logger?.info(temp)
        
        // then
        XCTAssertEqual(logger?.logMessage, "[EvolvKit] Foo(description: \"temp\", value: 1, bar: true)")
    }

}
