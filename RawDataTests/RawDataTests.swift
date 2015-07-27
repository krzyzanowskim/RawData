//
//  RawDataTests.swift
//  RawDataTests
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import XCTest
@testable import RawData

class RawDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let data = RawData(count: 5)
        XCTAssert(data.count == 5, "Invalid count")
        XCTAssert(data[0] == 0, "Invalid first value")
    }
    
    func testArrayLiteralConvertible() {
        let data:RawData = [1,2,3]
        XCTAssertTrue(data[0] == 1 && data[1] == 2 && data[2] == 3)
    }
    
    func testIntegerLiteralConvertible() {
        let data:RawData = 5
        XCTAssertTrue(data[0] == 5)
    }
    
    func testCustomStringConvertible() {
        XCTAssertTrue(([1,2,3,4,5,6] as RawData).description == "<01020304 0506>")
        XCTAssertTrue(([1,2] as RawData).description == "<0102>")
        XCTAssertTrue(([] as RawData).description == "<>")
    }
    
    func testReplace() {
        let data:RawData = [1,2,3,4]
        data[0] = 9
        XCTAssertTrue(data[0] == 9)
    }
    
    func testRangeReplaceableCollectionType() {
        let data:RawData = [1,2,3,4,5,6,7,8,9,10]
        data.replaceRange(0...3, with: [10,9,8])
        XCTAssertTrue(data[0] == 10 && data[1] == 9 && data[2] == 8 && data[3] == 4)
    }
    
    func testCount() {
        let data:RawData = [1,2,3]
        XCTAssertTrue(data.count == 3)
        XCTAssertEqual(data.endIndex, 3)
        
        let dataEmpty:RawData = []
        XCTAssertEqual(dataEmpty.count, 0)
        XCTAssertEqual(dataEmpty.endIndex, 0)
    }
}
