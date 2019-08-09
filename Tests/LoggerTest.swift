//
//  LoggerTest.swift
//  EvolvKit iOS Tests
//
//  Created by divbyzero on 09/08/2019.
//  Copyright © 2019 Evolv. All rights reserved.
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
