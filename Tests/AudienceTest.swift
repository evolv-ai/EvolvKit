//
//  AudienceTest.swift
//  EvolvKit iOS Tests
//
//  Created by divbyzero on 27/08/2019.
//  Copyright © 2019 Evolv. All rights reserved.
//

import XCTest
@testable import EvolvKit

class AudienceTest: XCTestCase {
    
    private var filterOneGroupKeyValueEqualAnd: EvolvRawAllocation?
    private var filterOneGroupKeyValueEqualOr: EvolvRawAllocation?
    private var filterOneGroupKeyValueNotEqualAnd: EvolvRawAllocation?
    private var filterOneGroupKeyValueNotEqualOr: EvolvRawAllocation?
    private var filterOneGroupKeyValueContainsAnd: EvolvRawAllocation?
    private var filterOneGroupKeyValueContainsOr: EvolvRawAllocation?
    private var filterOneGroupKeyValueNotContainsAnd: EvolvRawAllocation?
    private var filterOneGroupKeyValueNotContainsOr: EvolvRawAllocation?
    private var filterOneGroupKeyExistsAnd: EvolvRawAllocation?
    private var filterOneGroupKeyExistsOr: EvolvRawAllocation?
    private var filterOneGroupKeyValueEqualsAndKeyValueContains: EvolvRawAllocation?
    private var filterOneGroupKeyValueEqualsOrKeyValueContains: EvolvRawAllocation?
    private var filterTwoGroupsKeyValueEqualsAndKeyValueContainsAndKeyValueEquals: EvolvRawAllocation?
    private var filterTwoGroupsKeyValueEqualsAndKeyValueContainsOrKeyValueEquals: EvolvRawAllocation?
    private var filterGroupWithoutRules: EvolvRawAllocation?
    private var filterGroupRuleInvalidValue: EvolvRawAllocation?
    private var filterExcluded: EvolvRawAllocation?
    private var filterWithoutAudienceQuery: EvolvRawAllocation?
    private var filterAudienceQueryIsNull: EvolvRawAllocation?
    
    override func setUp() {
        super.setUp()
        
        let rawAllocations = TestData.rawAllocationsWithAudience
        
        filterOneGroupKeyValueEqualAnd = rawAllocations[0]
        filterOneGroupKeyValueEqualOr = rawAllocations[1]
        filterOneGroupKeyValueNotEqualAnd = rawAllocations[2]
        filterOneGroupKeyValueNotEqualOr = rawAllocations[3]
        filterOneGroupKeyValueContainsAnd = rawAllocations[4]
        filterOneGroupKeyValueContainsOr = rawAllocations[5]
        filterOneGroupKeyValueNotContainsAnd = rawAllocations[6]
        filterOneGroupKeyValueNotContainsOr = rawAllocations[7]
        filterOneGroupKeyExistsAnd = rawAllocations[8]
        filterOneGroupKeyExistsOr = rawAllocations[9]
        filterOneGroupKeyValueEqualsAndKeyValueContains = rawAllocations[10]
        filterOneGroupKeyValueEqualsOrKeyValueContains = rawAllocations[11]
        filterTwoGroupsKeyValueEqualsAndKeyValueContainsAndKeyValueEquals = rawAllocations[12]
        filterTwoGroupsKeyValueEqualsAndKeyValueContainsOrKeyValueEquals = rawAllocations[13]
        filterGroupWithoutRules = rawAllocations[14]
        filterGroupRuleInvalidValue = rawAllocations[15]
        filterExcluded = rawAllocations[16]
        filterWithoutAudienceQuery = rawAllocations[17]
        filterAudienceQueryIsNull = rawAllocations[18]
    }
    
    override func tearDown() {
        super.tearDown()
        
        filterOneGroupKeyValueEqualAnd = nil
        filterOneGroupKeyValueEqualOr = nil
        filterOneGroupKeyValueNotEqualAnd = nil
        filterOneGroupKeyValueNotEqualOr = nil
        filterOneGroupKeyValueContainsAnd = nil
        filterOneGroupKeyValueContainsOr = nil
        filterOneGroupKeyValueNotContainsAnd = nil
        filterOneGroupKeyValueNotContainsOr = nil
        filterOneGroupKeyExistsAnd = nil
        filterOneGroupKeyExistsOr = nil
        filterOneGroupKeyValueEqualsAndKeyValueContains = nil
        filterOneGroupKeyValueEqualsOrKeyValueContains = nil
        filterTwoGroupsKeyValueEqualsAndKeyValueContainsAndKeyValueEquals = nil
        filterTwoGroupsKeyValueEqualsAndKeyValueContainsOrKeyValueEquals = nil
        filterGroupWithoutRules = nil
        filterGroupRuleInvalidValue = nil
        filterExcluded = nil
        filterWithoutAudienceQuery = nil
        filterAudienceQueryIsNull = nil
    }
    
    func test_FilterExcluded() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterExcluded else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
    }
    
    func test_FilterNoAudienceQuery() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterWithoutAudienceQuery else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterNullAudienceQuery() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterAudienceQueryIsNull else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterEmptyUserAttributes() {
        // given
        let userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterAudienceQueryIsNull else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueEqualAnd() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueEqualAnd else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        userAttributes["country"] = "uk"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueEqualOr() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueEqualOr else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "uk"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueNotEqualAnd() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueNotEqualAnd else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "uk"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
    }
    
    func test_FilterOneGroupKeyValueNotEqualOr() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueNotEqualOr else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "uk"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
    }
    
    func test_FilterOneGroupKeyValueContainsAnd() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueContainsAnd else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueContainsOr() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueContainsOr else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueNotContainsAnd() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueNotContainsAnd else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should not  be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
    }
    
    func test_FilterOneGroupKeyValueNotContainsOr() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueNotContainsOr else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant does not have a key value matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key value matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
    }
    
    func test_FilterOneGroupKeyExistsAnd() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyExistsAnd else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyExistsOr() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyExistsOr else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant does not have a user attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueEqualsAndKeyValueContains() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueEqualsAndKeyValueContains else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has only one user attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has one key that does not match the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterOneGroupKeyValueEqualsOrKeyValueContains() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterOneGroupKeyValueEqualsOrKeyValueContains else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has only one user attribute matching the audience query they should not be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has one key that does not match the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "80011"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterTwoGroupsKeyValueEqualsAndKeyValueContainsAndKeyValueEquals() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterTwoGroupsKeyValueEqualsAndKeyValueContainsAndKeyValueEquals else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["target"] = "true"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertTrue(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        userAttributes["target"] = "true"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterTwoGroupsKeyValueEqualsAndKeyValueContainsOrKeyValueEquals() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterTwoGroupsKeyValueEqualsAndKeyValueContainsOrKeyValueEquals else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes = [:]
        userAttributes["target"] = "true"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
        
        // if participant has a key matching the audience query they should not be filtered
        userAttributes = [:]
        userAttributes["country"] = "us"
        userAttributes["post_code"] = "94110"
        userAttributes["target"] = "true"
        
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterGroupsWithoutRules() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterGroupWithoutRules else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }
    
    func test_FilterGroupRuleInvalidValue() {
        // given
        var userAttributes: [String: String] = [:]
        var filter: Bool
        
        // when & then
        guard let rawAllocation = filterGroupRuleInvalidValue else {
            XCTFail("A non-empty allocation is expected")
            return
        }
        
        // if participant has one group attribute matching the audience query they should be filtered
        userAttributes["country"] = "us"
        filter = rawAllocation.isFilter(userAttributes: userAttributes)
        XCTAssertFalse(filter)
    }

}
