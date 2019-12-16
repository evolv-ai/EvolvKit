//
//  RawAllocationNodeTest.swift
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

class RawAllocationNodeTest: XCTestCase {

    var jsonDecoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        
        jsonDecoder = JSONDecoder()
    }

    override func tearDown() {
        super.tearDown()
        
        jsonDecoder = nil
    }

    func test_Init() {
        // given
        let nodeNumber1 = EvolvRawAllocationNode(5)
        let nodeNumber2 = EvolvRawAllocationNode(10.2)
        let nodeNumber3 = EvolvRawAllocationNode(0)
        let nodeNumber4 = EvolvRawAllocationNode(Int8(12))
        let nodeNumber5 = EvolvRawAllocationNode(-1_234_567)
        let nodeNumber6 = EvolvRawAllocationNode(1)
        let nodeString1 = EvolvRawAllocationNode("")
        let nodeString2 = EvolvRawAllocationNode("foo")
        let nodeBool1 = EvolvRawAllocationNode(false)
        let nodeBool2 = EvolvRawAllocationNode(true)
        let nodeBool3 = EvolvRawAllocationNode(0)
        let nodeBool4 = EvolvRawAllocationNode(1)
        let nodeArray1 = EvolvRawAllocationNode([])
        let nodeArray2 = EvolvRawAllocationNode([1, 2, 3])
        let nodeArray3 = EvolvRawAllocationNode(["1", "2", "3"])
        let nodeArray4 = EvolvRawAllocationNode(["1", 2, true])
        let nodeDict1 = EvolvRawAllocationNode([:])
        let nodeDict2 = EvolvRawAllocationNode(["1": 2, "3": 4])
        let nodeNull1 = EvolvRawAllocationNode(NSNull())
        let nodeNull2 = EvolvRawAllocationNode.null
        let nodeUnknown = EvolvRawAllocationNode(Data())
        
        // when & then
        // number
        XCTAssertEqual(nodeNumber1.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber1, 5)
        XCTAssertEqual(nodeNumber2.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber2, 10.2)
        XCTAssertEqual(nodeNumber3.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber3, 0)
        XCTAssertEqual(nodeNumber4.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber4, 12)
        XCTAssertEqual(nodeNumber5.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber5, -1234567)
        XCTAssertEqual(nodeNumber6.type, EvolvRawAllocationNode.NodeType.number)
        XCTAssertEqual(nodeNumber6, 1)
        
        // string
        XCTAssertEqual(nodeString1.type, EvolvRawAllocationNode.NodeType.string)
        XCTAssertEqual(nodeString1, "")
        XCTAssertEqual(nodeString2.type, EvolvRawAllocationNode.NodeType.string)
        XCTAssertEqual(nodeString2, "foo")
        
        // bool
        XCTAssertEqual(nodeBool1.type, EvolvRawAllocationNode.NodeType.bool)
        XCTAssertEqual(nodeBool1, false)
        XCTAssertEqual(nodeBool2.type, EvolvRawAllocationNode.NodeType.bool)
        XCTAssertEqual(nodeBool2, true)
        XCTAssertNotEqual(nodeBool3.type, EvolvRawAllocationNode.NodeType.bool)
        XCTAssertNotEqual(nodeBool4.type, EvolvRawAllocationNode.NodeType.bool)
        
        // array
        XCTAssertEqual(nodeArray1.type, EvolvRawAllocationNode.NodeType.array)
        XCTAssertEqual(nodeArray1, [])
        XCTAssertEqual(nodeArray2.type, EvolvRawAllocationNode.NodeType.array)
        XCTAssertEqual(nodeArray2, [1, 2, 3])
        XCTAssertEqual(nodeArray3.type, EvolvRawAllocationNode.NodeType.array)
        XCTAssertEqual(nodeArray3, ["1", "2", "3"])
        XCTAssertEqual(nodeArray4.type, EvolvRawAllocationNode.NodeType.array)
        XCTAssertEqual(nodeArray4, ["1", 2, true])
        
        // dictionary
        XCTAssertEqual(nodeDict1.type, EvolvRawAllocationNode.NodeType.dictionary)
        XCTAssertEqual(nodeDict1, [:])
        XCTAssertEqual(nodeDict2.type, EvolvRawAllocationNode.NodeType.dictionary)
        XCTAssertEqual(nodeDict2, ["1": 2, "3": 4])
        
        // null
        XCTAssertEqual(nodeNull1.type, .null)
        XCTAssertEqual(nodeNull1, EvolvRawAllocationNode(NSNull()))
        XCTAssertEqual(nodeNull2.type, .null)
        XCTAssertEqual(nodeNull2, EvolvRawAllocationNode(NSNull()))
        
        // unknown
        XCTAssertEqual(nodeUnknown.type, .unknown)
    }
    
    func test_Equatable() {
        XCTAssertEqual(EvolvRawAllocationNode(100), EvolvRawAllocationNode(100))
        XCTAssertNotEqual(EvolvRawAllocationNode(123.4567), EvolvRawAllocationNode(123.456))
        XCTAssertNotEqual(EvolvRawAllocationNode("123.456"), EvolvRawAllocationNode(123.456))
        XCTAssertEqual(EvolvRawAllocationNode(""), EvolvRawAllocationNode(""))
        XCTAssertEqual(EvolvRawAllocationNode("foo"), EvolvRawAllocationNode("foo"))
        XCTAssertEqual(EvolvRawAllocationNode(true), EvolvRawAllocationNode(true))
        XCTAssertEqual(EvolvRawAllocationNode(false), EvolvRawAllocationNode(false))
        XCTAssertNotEqual(EvolvRawAllocationNode(true), EvolvRawAllocationNode(false))
        XCTAssertEqual(EvolvRawAllocationNode([]), EvolvRawAllocationNode([]))
        XCTAssertEqual(EvolvRawAllocationNode([1, 2, 3]), EvolvRawAllocationNode([1, 2, 3]))
        XCTAssertNotEqual(EvolvRawAllocationNode([1, 2, 3]), EvolvRawAllocationNode([3, 2, 1]))
        XCTAssertEqual(EvolvRawAllocationNode(["1": 2, "3": 4]), EvolvRawAllocationNode(["3": 4, "1": 2]))
        XCTAssertEqual(EvolvRawAllocationNode(NSNull()), EvolvRawAllocationNode(NSNull()))
        XCTAssertEqual(EvolvRawAllocationNode.null, EvolvRawAllocationNode(NSNull()))
    }
    
    func test_TypeCasting() {
        // given
        let nodeNumber1 = EvolvRawAllocationNode(5)
        let nodeNumber2 = EvolvRawAllocationNode(Float(543.21))
        let nodeNumber3 = EvolvRawAllocationNode(10.2)
        
        let nodeString = EvolvRawAllocationNode("foo")
        let nodeBool = EvolvRawAllocationNode(true)
        let nodeArray1 = EvolvRawAllocationNode([1, 2, 3])
        let nodeArray2 = EvolvRawAllocationNode(["1", "2", "3"])
        let nodeDict = EvolvRawAllocationNode(["1": 2, "3": 4])
        
        // when & then
        XCTAssertNotNil(nodeNumber1.int)
        XCTAssertNil(nodeNumber1.array)
        XCTAssertNotNil(nodeNumber2.float)
        XCTAssertNil(nodeNumber2.array)
        XCTAssertNotNil(nodeNumber3.double)
        XCTAssertNil(nodeNumber3.dictionary)
        XCTAssertNotNil(nodeString.string)
        XCTAssertNil(nodeString.bool)
        XCTAssertNotNil(nodeBool.bool)
        XCTAssertNil(nodeBool.string)
        XCTAssertNotNil(nodeArray1.array)
        XCTAssertNil(nodeArray1.dictionary)
        XCTAssertNotNil(nodeArray2.array)
        XCTAssertNil(nodeArray2.string)
        XCTAssertNotNil(nodeDict.dictionary)
        XCTAssertNil(nodeDict.array)
    }
    
    func test_Decode() {
        // given
        let jsonString = """
        {
            "best":{
                "baked":{
                    "cookie":true,
                    "cake":false
                }
            }
        }
        """
        var node: EvolvRawAllocationNode?
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            node = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(node)
        XCTAssertEqual(node?.type, .dictionary)
    }
    
    func test_DecodeDictionary() {
        // given
        let jsonString1 = "{}"
        let jsonString2 = "{\"size\": 126}"
        let jsonString3 = "{\"scale\": 10.2}"
        let jsonString4 = "{\"isPromo\": true, \"demo\": {\"bar\": 50}}"
        let jsonString5 = "{\"a\": {\"b\": {\"c\": {\"d\": {\"e\": {\"f\": {\"foo\": \"bar\", \"g\": {\"h\":{\"value\": 1234}}}}}}}}}"
        var node1: EvolvRawAllocationNode?
        var node2: EvolvRawAllocationNode?
        var node3: EvolvRawAllocationNode?
        var node4: EvolvRawAllocationNode?
        var node5: EvolvRawAllocationNode?
        
        // when
        do {
            let data1 = jsonString1.data(using: .utf8)!
            let data2 = jsonString2.data(using: .utf8)!
            let data3 = jsonString3.data(using: .utf8)!
            let data4 = jsonString4.data(using: .utf8)!
            let data5 = jsonString5.data(using: .utf8)!
            node1 = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data1)
            node2 = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data2)
            node3 = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data3)
            node4 = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data4)
            node5 = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data5)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(node1)
        XCTAssertEqual(node1?.type, .dictionary)
        XCTAssertNotNil(node2)
        XCTAssertEqual(node2?.type, .dictionary)
        XCTAssertEqual(try? node2?.node(forKey: "size"), 126)
        XCTAssertNotNil(node3)
        XCTAssertEqual(node3?.type, .dictionary)
        XCTAssertEqual(try? node3?.node(forKey: "scale"), 10.2)
        XCTAssertNotNil(node4)
        XCTAssertEqual(node4?.type, .dictionary)
        XCTAssertEqual(try? node4?.node(forKey: "demo.bar"), 50)
        XCTAssertNotNil(node5)
        XCTAssertEqual(node5?.type, .dictionary)
        XCTAssertEqual(try? node5?.node(forKey: "a.b.c.d.e.f.foo"), "bar")
        XCTAssertEqual(try? node5?.node(forKey: "a.b.c.d.e.f.g.h.value"), 1234)
    }
    
    func test_KeyPath() {
        // given
        let jsonString = """
        {
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
            }
        }
        """
        var node: EvolvRawAllocationNode?
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            node = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertNotNil(node)
        XCTAssertEqual(node?.type, .dictionary)
        XCTAssertEqual(try? node?.node(forKey: "best")?.type, .dictionary)
        XCTAssertEqual(try? node?.node(forKey: "best.baked.cake"), false)
        XCTAssertEqual(try? node?.node(forKey: "utensils.knives.drawer")?[1], "paring")
    }
    
    func test_ThrowIncorrectKeyError() {
        // given
        let jsonString = """
        {
            "best":{
                "baked":{
                    "cookie":true,
                    "cake":false
                }
            }
        }
        """
        var node: EvolvRawAllocationNode?
        let key = "best.baked.cake2"
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            node = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertThrowsError(try node?.node(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvRawAllocationNode.Error,
                           EvolvRawAllocationNode.Error.incorrectKey(key: key))
        }
    }
    
    func test_ThrowEmptyKeyError() {
        // given
        let jsonString = """
        {
            "best":{
                "baked":{
                    "cookie":true,
                    "cake":false
                }
            }
        }
        """
        var node: EvolvRawAllocationNode?
        let key = ""
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            node = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertThrowsError(try node?.node(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvRawAllocationNode.Error,
                           EvolvRawAllocationNode.Error.emptyKey)
        }
    }
    
    func test_ThrowNotDictionaryNodeTypeError() {
        // given
        let jsonString = "[]"
        var node: EvolvRawAllocationNode?
        let key = "foo.bar"
        
        // when
        do {
            let data = jsonString.data(using: .utf8)!
            node = try jsonDecoder.decode(EvolvRawAllocationNode.self, from: data)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // then
        XCTAssertThrowsError(try node?.node(forKey: key)) { error in
            XCTAssertEqual(error as! EvolvRawAllocationNode.Error,
                           EvolvRawAllocationNode.Error.notDictionaryType)
        }
    }

}
