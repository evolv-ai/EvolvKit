//
//  AllocationsTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class AllocationsTest: XCTestCase {
  
  public static let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  private let rawMultiAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}," +
  "{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid_2\",\"cid\":\"test_cid_2\",\"genome\":{\"best\":{\"baked\":{\"cookie\":true,\"cake\":false}},\"utensils\":{\"knives\":{\"drawer\":[\"butcher\",\"paring\"]},\"spoons\":{\"wooden\":\"oak\",\"metal\":\"steel\"}},\"measure\":{\"cups\":2.0}},\"excluded\":false}]"
  private let rawMultiAllocationWithDups: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}," +
  "{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid_2\",\"cid\":\"test_cid_2\",\"genome\":{\"best\":{\"baked\":{\"cookie\":true,\"cake\":false}},\"utensils\":{\"knives\":{\"drawer\":[\"butcher\",\"paring\"]},\"spoons\":{\"wooden\":\"oak\",\"metal\":\"steel\"}},\"algorithms\":{\"feature_importance\":true}},\"excluded\":false}]"
    
  func parseRawAllocations(raw: String) -> [JSON] {
    var allocations = [JSON]()
    if let dataFromString = raw.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      allocations = try! JSON(data: dataFromString).arrayValue
    }
    return allocations
  }

  func testGetValueFromAllocationGenome() {
    do {
      let participant = EvolvParticipant.builder().build()
      let allocations = Allocations(allocations: parseRawAllocations(raw: AllocationsTest.rawAllocation))
      let defaultBool: Bool = true
      let defaultDouble: Double = 10.0
      let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                      defaultBool, participant)
      let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                      defaultDouble, participant)
      XCTAssertEqual(featureImportance, false)
      XCTAssertEqual(weightingDistance, 2.5)
    } catch let error {
      XCTFail(error.localizedDescription)
    }
  }

  func testGetValueFromMultiAllocationGenome() {
    do {
      let participant: EvolvParticipant = EvolvParticipant.builder().build()
      let allocations: Allocations = Allocations(allocations: parseRawAllocations(raw: rawMultiAllocation))
      let defaultBool: Bool = true
      let defaultDouble: Double = 10.0
      let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                      defaultBool, participant)
      let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                      defaultDouble, participant)
      XCTAssertEqual(featureImportance, false)
      XCTAssertEqual(weightingDistance, 2.5)
    } catch (let e) {
      XCTFail(e.localizedDescription)
    }
  }

  func testGetValueFromMultiAllocationWithDupsGenome() {
    do {
      let participant: EvolvParticipant = EvolvParticipant.builder().build()
      let allocations: Allocations = Allocations(allocations: parseRawAllocations(raw: rawMultiAllocationWithDups))
      let defaultBool: Bool = true
      let defaultDouble: Double = 10.0
      let featureImportance = try allocations.getValueFromAllocations("algorithms.feature_importance",
                                                                      defaultBool, participant)
      let weightingDistance = try allocations.getValueFromAllocations("search.weighting.distance",
                                                                      defaultDouble, participant)
      XCTAssertEqual(featureImportance, false)
      XCTAssertEqual(weightingDistance, 2.5)
    } catch (let e) {
      XCTFail(e.localizedDescription)
    }
  }
  
  func testGetActiveExperiments () {
    let allocations: Allocations = Allocations(allocations: parseRawAllocations(raw: rawMultiAllocation))
    let activeExperiments: Set<String> = allocations.getActiveExperiments()
    var expected: Set<String> = Set()
    expected.update(with: "test_eid")
    expected.update(with: "test_eid_2")
    XCTAssertEqual(expected, activeExperiments)
  }

}
