//
//  TestData.swift
//  EvolvKit iOS
//
//  Created by divbyzero on 31/07/2019.
//  Copyright © 2019 Evolv. All rights reserved.
//

import Foundation
@testable import EvolvKit

enum TestData {
    
    private static var jsonDecoder: JSONDecoder = JSONDecoder()
    private static let logger = EvolvLogger.shared
    
    static var rawAllocationsString: String = #"""
    [
       {
          "uid":"test_uid",
          "sid":"test_sid",
          "eid":"test_eid",
          "cid":"test_cid",
          "genome":{
             "search":{
                "weighting":{
                   "distance":2.5,
                   "dealer_score":2.5
                }
             },
             "pages":{
                "all_pages":{
                   "header_footer":[
                      "blue",
                      "white"
                   ]
                },
                "testing_page":{
                   "megatron":"none",
                   "header":"white"
                }
             },
             "algorithms":{
                "feature_importance":false
             }
          },
          "excluded":false
       }
    ]
    """#
    static var rawMultiAllocationsString: String = #"""
    [
       {
          "uid":"test_uid",
          "sid":"test_sid",
          "eid":"test_eid",
          "cid":"test_cid",
          "genome":{
             "search":{
                "weighting":{
                   "distance":2.5,
                   "dealer_score":2.5
                }
             },
             "pages":{
                "all_pages":{
                   "header_footer":[
                      "blue",
                      "white"
                   ]
                },
                "testing_page":{
                   "megatron":"none",
                   "header":"white"
                }
             },
             "algorithms":{
                "feature_importance":false
             }
          },
          "excluded":false
       },
       {
          "uid":"test_uid",
          "sid":"test_sid",
          "eid":"test_eid_2",
          "cid":"test_cid_2",
          "genome":{
             "best":{
                "baked":{
                   "cookie":true,
                   "cake":false
                }
             },
             "utensils":{
                "knives":{
                   "drawer":[
                      "butcher",
                      "paring"
                   ]
                },
                "spoons":{
                   "wooden":"oak",
                   "metal":"steel"
                }
             },
             "measure":{
                "cups":2.0
             }
          },
          "excluded":false
       }
    ]
    """#
    static var rawMultiAllocationsWithDupsString: String = #"""
    [
       {
          "uid":"test_uid",
          "sid":"test_sid",
          "eid":"test_eid",
          "cid":"test_cid",
          "genome":{
             "search":{
                "weighting":{
                   "distance":2.5,
                   "dealer_score":2.5
                }
             },
             "pages":{
                "all_pages":{
                   "header_footer":[
                      "blue",
                      "white"
                   ]
                },
                "testing_page":{
                   "megatron":"none",
                   "header":"white"
                }
             },
             "algorithms":{
                "feature_importance":false
             }
          },
          "excluded":false
       },
       {
          "uid":"test_uid",
          "sid":"test_sid",
          "eid":"test_eid_2",
          "cid":"test_cid_2",
          "genome":{
             "best":{
                "baked":{
                   "cookie":true,
                   "cake":false
                }
             },
             "utensils":{
                "knives":{
                   "drawer":[
                      "butcher",
                      "paring"
                   ]
                },
                "spoons":{
                   "wooden":"oak",
                   "metal":"steel"
                }
             },
             "algorithms":{
                "feature_importance":true
             }
          },
          "excluded":false
       }
    ]
    """#
    
    static var rawAllocations: [EvolvRawAllocation] {
        return decode(rawAllocationsString)
    }
    
    static var rawMultiAllocations: [EvolvRawAllocation] {
        return decode(rawMultiAllocationsString)
    }
    
    static var rawMultiAllocationsWithDups: [EvolvRawAllocation] {
        return decode(rawMultiAllocationsWithDupsString)
    }
    
    static var rawAllocationsWithoutGenome: [EvolvRawAllocation] {
        return [EvolvRawAllocation(experimentId: "test_eid",
                                   userId: "test_uid",
                                   candidateId: "test_cid",
                                   genome: EvolvRawAllocationNode.null,
                                   excluded: false,
                                   sessionId: "test_sid")]
    }
    
}

extension TestData {
    
    private static func decode(_ stringJSON: String) -> [EvolvRawAllocation] {
        var rawAllocations: [EvolvRawAllocation] = []
        
        do {
            rawAllocations = try jsonDecoder.decode([EvolvRawAllocation].self, from: stringJSON.data(using: .utf8)!)
        } catch let error {
            logger.error(error)
        }
        
        return rawAllocations
    }
    
}
